%lang starknet
# %builtins pedersen range_check ecdsa bitwise

from contracts.starknet.keccak.keccak256 import keccak256
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.math import split_felt, unsigned_div_rem, assert_le, assert_in_range
from starkware.cairo.common.math_cmp import is_nn, is_le
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.pow import pow

func mask{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value, byte_index, bytes_len) -> (
        result : felt):
    alloc_locals

    let start_bit = byte_index * 8
    let end_bit = start_bit + bytes_len * 8

    # mask = 2 ^ (end_bit) - 2 ^ (start_bit)
    let (mask_sub) = pow(2, start_bit)
    let (mask) = pow(2, end_bit)
    let mask = mask - mask_sub

    let (result) = bitwise_and(value, mask)
    return (result)
end

func move_left{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value, byte_index, bytes) -> (
        result : felt):
    alloc_locals
    let (masked) = mask(value, byte_index, 1)
    let (shift) = pow(2, bytes * 8)
    let shifted = masked * shift
    return (shifted)
end

func move_right{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value, byte_index, bytes) -> (
        result : felt):
    alloc_locals
    let (masked) = mask(value, byte_index, 1)
    let (shift) = pow(2, bytes * 8)
    let shifted = masked / shift
    return (shifted)
end

func reverse_bytes{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value : felt) -> (result : felt):
    alloc_locals
    let (l0) = move_left(value, 0, 7)
    let (l1) = move_left(value, 1, 5)
    let (l2) = move_left(value, 2, 3)
    let (l3) = move_left(value, 3, 1)
    let (l4) = move_right(value, 4, 1)
    let (l5) = move_right(value, 5, 3)
    let (l6) = move_right(value, 6, 5)
    let (l7) = move_right(value, 7, 7)
    let result = l0 + l1 + l2 + l3 + l4 + l5 + l6 + l7
    return (result)
end

func keccak_result_to_uint256{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        r0 : felt, r1 : felt, r2 : felt, r3 : felt) -> (res : Uint256):
    alloc_locals
    # little to big endian
    let (reversed0) = reverse_bytes(r0)
    let (reversed1) = reverse_bytes(r1)
    let (reversed2) = reverse_bytes(r2)
    let (reversed3) = reverse_bytes(r3)

    let low = reversed3 + reversed2 * 2 ** 64
    let high = reversed1 + reversed0 * 2 ** 64

    return (Uint256(low, high))
end

func split_uint256{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value : Uint256) -> (
        res0 : felt, res1 : felt, res2 : felt, res3 : felt):
    alloc_locals
    local first_mask = 2 ** 64 - 1
    local second_mask = 2 ** 128 - 1 - first_mask
    local second_shift = 2 ** 64

    let (r0) = bitwise_and(value.low, first_mask)

    let (second_masked) = bitwise_and(value.low, second_mask)
    let r1 = second_masked / second_shift

    let (r2) = bitwise_and(value.high, first_mask)

    let (fourth_masked) = bitwise_and(value.high, second_mask)
    let r3 = fourth_masked / second_shift

    return (r0, r1, r2, r3)
end

func split_uint256_array{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        values_len : felt, values : Uint256*, result : felt*) -> (res : felt*):
    alloc_locals
    if values_len == 0:
        return (result)
    end

    let value = [values]
    let (r0, r1, r2, r3) = split_uint256(value)
    # To little endian
    let (le0) = reverse_bytes(r0)
    let (le1) = reverse_bytes(r1)
    let (le2) = reverse_bytes(r2)
    let (le3) = reverse_bytes(r3)

    assert result[0] = le3
    assert result[1] = le2
    assert result[2] = le1
    assert result[3] = le0

    split_uint256_array(values_len - 1, values + 2, result + 4)
    return (result)
end

# Handles additional 2 bytes is were provided
func handle_leftover{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        uint256_count : felt, rem_bytes : felt, values : Uint256*, inputs : felt*) -> ():
    alloc_locals
    if rem_bytes == 0:
        return ()
    end

    if rem_bytes != 2:
        assert 1 = 0
    end

    let value = values[uint256_count]
    let (new_0) = move_right(value.low, 1, 1)
    let (new_1) = move_left(value.low, 0, 1)
    let new_value = new_0 + new_1
    let target_index = uint256_count * 4
    assert inputs[target_index] = new_value
    return ()
end

# Supports bytes = 32*n + k, where k = 0 or k = 2 and n >= 0
func uint256_keccak{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        values : Uint256*, bytes : felt) -> (res : Uint256):
    alloc_locals
    let (uint256_count, rem_bytes) = unsigned_div_rem(bytes, 32)
    let (inputs : felt*) = alloc()
    split_uint256_array(uint256_count, values, inputs)
    handle_leftover(uint256_count, rem_bytes, values, inputs)

    let (local keccak_ptr_start : felt*) = alloc()
    let keccak_ptr = keccak_ptr_start
    let (local output : felt*) = keccak256{keccak_ptr=keccak_ptr}(inputs, bytes)

    let (res) = keccak_result_to_uint256(output[0], output[1], output[2], output[3])
    return (res)
end
