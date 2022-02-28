from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_le
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_nn_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_in_range
from contracts.starknet.keccak.pow import pow
from contracts.starknet.keccak.int_sequence import IntsSequence

# func swap_endianness_many_words{ range_check_ptr, bitwise_ptr : BitwiseBuiltin* }(input: IntsSequence) -> (output: IntsSequence):
#     alloc_locals
#     let (local acc : felt*) = alloc()
#     swap_endianness_many_words_rec(input, acc, 0)
#     local res: IntsSequence = IntsSequence(acc, input.element_size_words, input.element_size_bytes)
#     return (res)
# end

func swap_endianness_four_words{ range_check_ptr, bitwise_ptr : BitwiseBuiltin* }(input: IntsSequence) -> (output: IntsSequence):
    alloc_locals
    let (local acc : felt*) = alloc()

    let (local swapped_input_0) = swap_endianness_64(input.element[0], 8)
    assert acc[0] = swapped_input_0

    let (local swapped_input_1) = swap_endianness_64(input.element[1], 8)
    assert acc[1] = swapped_input_1

    let (local swapped_input_2) = swap_endianness_64(input.element[2], 8)
    assert acc[2] = swapped_input_2

    let (local swapped_input_3) = swap_endianness_64(input.element[3], 8)
    assert acc[3] = swapped_input_3

    local res: IntsSequence = IntsSequence(acc, input.element_size_words, input.element_size_bytes)
    return (res)
end

# func swap_endianness_many_words_rec{ range_check_ptr, bitwise_ptr : BitwiseBuiltin* }(
#     input: IntsSequence,
#     acc: felt*,
#     current_word: felt):
#     alloc_locals

#     if current_word == input.element_size_words:
#         return ()
#     end

#     # Is 0 when it is last word
#     let is_last_word = input.element_size_words - current_word - 1
#     local proper_len

#     if is_last_word == 0:
#         let (_, last_word_len) = unsigned_div_rem(input.element_size_bytes, 8)
        
#         if last_word_len == 0:
#             proper_len = 8
#         else:
#             proper_len = last_word_len
#         end
#     else:
#         proper_len = 8
#     end

#     let swapped: felt = swap_endianness_64(input.element[current_word], proper_len)
#     assert acc[current_word] = swapped
#     return swap_endianness_many_words_rec(input, acc, current_word + 1)
# end

func swap_endianness_64{ range_check_ptr, bitwise_ptr : BitwiseBuiltin* }(input: felt, size: felt) -> (output: felt):
    alloc_locals
    let (local output : felt*) = alloc()

    # verifies word fits in 64bits
    assert_le(input, 2**64 - 1)

    # swapped_bytes = ((word & 0xFF00FF00FF00FF00) >> 8) | ((word & 0x00FF00FF00FF00FF) << 8)
    let (left_part, _) = unsigned_div_rem(input, 256)

    assert bitwise_ptr[0].x = left_part
    assert bitwise_ptr[0].y = 0x00FF00FF00FF00FF
    
    assert bitwise_ptr[1].x = input * 256
    assert bitwise_ptr[1].y = 0xFF00FF00FF00FF00
    
    let swapped_bytes = bitwise_ptr[0].x_and_y + bitwise_ptr[1].x_and_y

    # swapped_2byte_pair = ((swapped_bytes & 0xFFFF0000FFFF0000) >> 16) | ((swapped_bytes & 0x0000FFFF0000FFFF) << 16)
    let (left_part2, _) = unsigned_div_rem(swapped_bytes, 2**16)

    assert bitwise_ptr[2].x = left_part2
    assert bitwise_ptr[2].y = 0x0000FFFF0000FFFF
    
    assert bitwise_ptr[3].x = swapped_bytes * 2**16
    assert bitwise_ptr[3].y = 0xFFFF0000FFFF0000
    
    let swapped_2bytes = bitwise_ptr[2].x_and_y + bitwise_ptr[3].x_and_y

    # swapped_4byte_pair = (swapped_2byte_pair >> 32) | ((swapped_2byte_pair << 32) % 2**64)
    let (left_part4, _) = unsigned_div_rem(swapped_2bytes, 2**32)

    assert bitwise_ptr[4].x = swapped_2bytes * 2**32
    assert bitwise_ptr[4].y = 0xFFFFFFFF00000000
    
    let swapped_4bytes = left_part4 + bitwise_ptr[4].x_and_y

    let bitwise_ptr = bitwise_ptr + 5 * BitwiseBuiltin.SIZE

    # Some Shiva-inspired code here
    let (local shift) = pow(2, ((8 - size) * 8))

    if size == 8:
        return (swapped_4bytes)
    else:
        let (shifted_4bytes, _) = unsigned_div_rem(swapped_4bytes, shift)
        return (shifted_4bytes)
    end
end