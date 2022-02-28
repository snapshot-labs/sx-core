%lang starknet

from contracts.starknet.secp.bigint import BigInt3, UnreducedBigInt5, nondet_bigint3, bigint_mul, BASE
from contracts.starknet.secp.secp import mul_s_inv
from contracts.starknet.secp.secp_ec import EcPoint, ec_mul, ec_add
from contracts.starknet.keccak.keccak import uint256_keccak
from starkware.cairo.common.math import assert_in_range, assert_not_equal, assert_not_zero
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor, bitwise_or
from starkware.cairo.common.uint256 import Uint256, uint256_sub
from starkware.cairo.common.alloc import alloc

# Performs (a * b) % m and returns normalized BigInt3
func mul_mod{range_check_ptr}(a : BigInt3, b : BigInt3, m : BigInt3) -> (res : BigInt3):
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack
        from starkware.python.math_utils import div_mod, safe_div

        a = pack(ids.a, PRIME)
        b = pack(ids.b, PRIME)
        product = a * b
        m = pack(ids.m, PRIME)

        value = res = product % m
    %}
    let (res) = nondet_bigint3()

    %{ value = k = product // m %}
    let (k) = nondet_bigint3()
    let (k_m) = bigint_mul(k, m)
    let (multiplied) = bigint_mul(a, b)

    # We need to verify that multiplied = k_m + res

    tempvar carry1 = (multiplied.d0 - k_m.d0 - res.d0) / BASE
    assert [range_check_ptr + 0] = carry1 + 2 ** 127

    tempvar carry2 = (multiplied.d1 - k_m.d1 - res.d1 + carry1) / BASE
    assert [range_check_ptr + 1] = carry2 + 2 ** 127

    tempvar carry3 = (multiplied.d2 - k_m.d2 - res.d2 + carry2) / BASE
    assert [range_check_ptr + 2] = carry3 + 2 ** 127

    tempvar carry4 = (multiplied.d3 - k_m.d3 + carry3) / BASE
    assert [range_check_ptr + 3] = carry4 + 2 ** 127

    assert multiplied.d4 - k_m.d4 + carry4 = 0

    let range_check_ptr = range_check_ptr + 4

    return (res)
end

# Performs (a - b) % m and returns normalized BigInt3
func bigint3_sub{range_check_ptr}(a : BigInt3, b : BigInt3) -> (res : BigInt3):
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import pack
        from starkware.python.math_utils import div_mod, safe_div

        a = pack(ids.a, PRIME)
        b = pack(ids.b, PRIME)

        value = res = a - b
    %}
    let (res) = nondet_bigint3()

    let s_0 = res.d0 + b.d0
    let s_1 = res.d1 + b.d1
    let s_2 = res.d2 + b.d2
    # We need to prove that a = res + b

    tempvar carry1 = (a.d0 - res.d0 - b.d0) / BASE
    assert [range_check_ptr + 0] = carry1 + 2 ** 127

    tempvar carry2 = (a.d1 - res.d1 - b.d1 + carry1) / BASE
    assert [range_check_ptr + 1] = carry2 + 2 ** 127

    assert a.d2 - res.d2 - b.d2 + carry2 = 0

    let range_check_ptr = range_check_ptr + 2

    return (res=res)
end

# Performs a % m and returns normalized BigInt3
func mod{range_check_ptr}(a : BigInt3, m : BigInt3) -> (res : BigInt3):
    let one = BigInt3(1, 0, 0)
    let (result) = mul_mod(a, one, m)
    return (result)
end

func add_mod{range_check_ptr}(a : BigInt3, b : BigInt3, m : BigInt3) -> (res : BigInt3):
    let s_0 = a.d0 + b.d0
    let s_1 = a.d1 + b.d1
    let s_2 = a.d2 + b.d2
    let sum = BigInt3(s_0, s_1, s_2)
    # This works because mod normalizes BigInt3
    let (res) = mod(sum, m)

    return (res)
end

# Performs (a ** p) % m
func pow_mod{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        a : BigInt3, p : BigInt3, m : BigInt3) -> (res : BigInt3):
    alloc_locals
    # p == 1
    if p.d0 == 1:
        if p.d1 == 0:
            if p.d2 == 0:
                let (res) = mul_mod(a, p, m)
                return (res)
            end
        end
    end

    let (is_odd) = bitwise_and(p.d0, 1)
    if is_odd == 1:
        let one = BigInt3(1, 0, 0)
        let (new_p) = bigint3_sub(p, one)
        let (rest) = pow_mod(a, new_p, m)
        let (res) = mul_mod(a, rest, m)
        return (res)
    end

    let two = BigInt3(2, 0, 0)
    let (half_p) = mul_s_inv(p, two, m)
    let (multiplier) = pow_mod(a, half_p, m)
    let (res) = mul_mod(multiplier, multiplier, m)
    return (res)
end

const A = 0

# B = 7
const B_0 = 7
const B_1 = 0
const B_2 = 0

# P = 2**256 - 2**32 - 97
const P_0 = 0x3ffffffffffffefffffc2f
const P_1 = 0x3fffffffffffffffffffff
const P_2 = 0xfffffffffffffffffffff

# PD = (P + 1) // 4
const PD_0 = 0x3fffffffffffffbfffff0c
const PD_1 = 0x3fffffffffffffffffffff
const PD_2 = 0x3ffffffffffffffffffff

# GX = 55066263022277343669578718895168534326250603453777594175500187360389116729240
const GX_0 = 0xe28d959f2815b16f81798
const GX_1 = 0xa573a1c2c1c0a6ff36cb7
const GX_2 = 0x79be667ef9dcbbac55a06

# GY = 32670510020758816978083085130507043184471273380659243275938904335757337482424
const GY_0 = 0x554199c47d08ffb10d4b8
const GY_1 = 0x2ff0384422a3f45ed1229a
const GY_2 = 0x483ada7726a3c4655da4f

# N = 115792089237316195423570985008687907852837564279074904382605163141518161494337
const N_0 = 0x8a03bbfd25e8cd0364141
const N_1 = 0x3ffffffffffaeabb739abd
const N_2 = 0xfffffffffffffffffffff

# (xcubedaxb - y * y) % P = 0
func assert_y_ok{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(y : BigInt3, xcubedaxb : BigInt3) -> ():
    alloc_locals
    let P = BigInt3(P_0, P_1, P_2)
    let two = BigInt3(2, 0, 0)
    let (y_sq) = pow_mod(y, two, P)
    let (xmod) = mod(xcubedaxb, P)
    assert y_sq.d0 = xmod.d0
    assert y_sq.d1 = xmod.d1
    assert y_sq.d2 = xmod.d2
    return ()
end

# (s % N) != 0
func assert_not_N_multiplication{range_check_ptr}(value : BigInt3) -> ():
    alloc_locals
    let N = BigInt3(N_0, N_1, N_2)
    let (result) = mod(value, N)
    if result.d0 == 0:
        if result.d1 == 0:
            if result.d2 == 0:
                # Result is 0, fail
                assert 1 = 0
            end
        end
    end

    return ()
end

func calc_y{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(v : felt, x : BigInt3) -> (y : BigInt3):
    alloc_locals
    let P = BigInt3(P_0, P_1, P_2)
    let PD = BigInt3(PD_0, PD_1, PD_2)
    let B = BigInt3(B_0, B_1, B_2)

    let (xcubedaxb) = mul_mod(x, x, P)
    let (xcubedaxb) = mul_mod(xcubedaxb, x, P)
    let (xcubedaxb) = add_mod(xcubedaxb, B, P)
    let (beta) = pow_mod(xcubedaxb, PD, P)

    # use_beta = (v % 2) ^ (beta % 2)
    let (v_mod_2) = bitwise_and(v, 1)
    let (beta_mod_2) = bitwise_and(beta.d0, 1)
    let (use_beta) = bitwise_xor(v_mod_2, beta_mod_2)

    if use_beta == 1:
        assert_y_ok(beta, xcubedaxb)
        return (beta)
    end

    let (y) = bigint3_sub(P, beta)
    assert_y_ok(y, xcubedaxb)
    return (y)
end

func ecdsa_raw_recover{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        hash : BigInt3, v : felt, r : BigInt3, s : BigInt3) -> (res : EcPoint):
    alloc_locals

    assert_not_N_multiplication(r)
    assert_not_N_multiplication(s)

    let P = BigInt3(P_0, P_1, P_2)
    let G = EcPoint(BigInt3(GX_0, GX_1, GX_2), BigInt3(GY_0, GY_1, GY_2))
    let N = BigInt3(N_0, N_1, N_2)

    let v = v + 27
    assert_in_range(v, 27, 34)

    let x = r
    let (y) = calc_y(v, x)
    let z = hash

    let R = EcPoint(x, y)
    # u1 = -z/r mod N
    let (u1) = mul_s_inv(z, r, N)
    let (u1) = bigint3_sub(N, u1)
    # u2 = s/r mod N
    let (u2) = mul_s_inv(s, r, N)

    let (first) = ec_mul(G, u1)
    let R = EcPoint(x, y)
    let (second) = ec_mul(R, u2)
    let (res) = ec_add(first, second)

    return (res)
end

func bigint3_to_uint256{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value : BigInt3) -> (
        res : Uint256):
    assert_in_range(value.d0, 0, BASE)
    assert_in_range(value.d1, 0, BASE)
    assert_in_range(value.d2, 0, BASE)

    # 128-86 = 42
    let low_d1_mask = 2 ** 42 - 1
    let (low_d1) = bitwise_and(value.d1, low_d1_mask)
    let low = value.d0 + low_d1 * BASE

    let high_d1_shift = 2 ** 42
    let high_d1 = (value.d1 - low_d1) / high_d1_shift
    let shift = 2 ** 44
    let high = value.d2 * shift + high_d1

    return (Uint256(low, high))
end

func uint256_to_bigint3{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value : Uint256) -> (
        res : BigInt3):
    assert_in_range(value.low, 0, 2 ** 128)
    assert_in_range(value.high, 0, 2 ** 128)

    let d0_mask = 2 ** 86 - 1
    let (d0) = bitwise_and(value.low, d0_mask)

    let d1_low = (value.low - d0) / 2 ** 86
    let d1_mask = 2 ** 44 - 1
    let (d1_high_masked) = bitwise_and(value.high, d1_mask)
    let d1_high = d1_high_masked * 2 ** 42
    let d1 = d1_low + d1_high

    let d2 = (value.high - d1_high_masked) / 2 ** 44
    return (BigInt3(d0, d1, d2))
end

func calc_eth_address{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        hash : Uint256, v : felt, r : Uint256, s : Uint256) -> (address : felt):
    alloc_locals

    let (hash_bigint3) = uint256_to_bigint3(hash)
    let (r_bigint3) = uint256_to_bigint3(r)
    let (s_bigint3) = uint256_to_bigint3(s)
    let (public_key) = ecdsa_raw_recover(hash_bigint3, v, r_bigint3, s_bigint3)

    let (x) = bigint3_to_uint256(public_key.x)
    let (y) = bigint3_to_uint256(public_key.y)
    let (inputs : Uint256*) = alloc()
    assert inputs[0] = x
    assert inputs[1] = y
    let (hashed) = uint256_keccak(inputs, 32 + 32)

    # Eth address is just lower 20 bytes of keccak(public_key)
    let high_mask = 2 ** 32 - 1
    let (high_part) = bitwise_and(high_mask, hashed.high)
    let address = high_part * 2 ** 128 + hashed.low
    return (address)
end
