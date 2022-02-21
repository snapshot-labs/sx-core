from contracts.starknet.secp.bigint import BASE, BigInt3, UnreducedBigInt3, nondet_bigint3
from contracts.starknet.secp.secp_def import SECP_REM

# Multiplies two values modulo the secp256k1 prime.
# The returned limbs may be above 3 * BASE.
#
# If each of the input limbs is in the range (-x, x), the result's limbs are guaranteed to be
# in the range (-x**2 * (2 ** 35.01), x**2 * (2 ** 35.01)).
#
# This means that if unreduced_mul is called on the result of nondet_bigint3, or the difference
# between two such results, we have:
#   Soundness guarantee: the limbs are in the range (-2**208.6, 2**208.6).
#   Completeness guarantee: the limbs are in the range (-2**207.01, 2**207.01).
func unreduced_mul(a : BigInt3, b : BigInt3) -> (res_low : UnreducedBigInt3):
    # The result of the product is:
    #   sum_{i, j} a.d_i * b.d_j * BASE**(i + j)
    # Since we are computing it mod secp256k1_prime, we replace the term
    #   a.d_i * b.d_j * BASE**(i + j)
    # where i + j >= 3 with
    #   a.d_i * b.d_j * BASE**(i + j - 3) * 4 * SECP_REM
    # since BASE ** 3 = 4 * SECP_REM (mod secp256k1_prime).
    return (
        UnreducedBigInt3(
        d0=a.d0 * b.d0 + (a.d1 * b.d2 + a.d2 * b.d1) * (4 * SECP_REM),
        d1=a.d0 * b.d1 + a.d1 * b.d0 + (a.d2 * b.d2) * (4 * SECP_REM),
        d2=a.d0 * b.d2 + a.d1 * b.d1 + a.d2 * b.d0))
end

# Computes the square of the given value modulo the secp256k1 prime.
# It has the same guarantees as in unreduced_mul(a, a).
func unreduced_sqr(a : BigInt3) -> (res_low : UnreducedBigInt3):
    tempvar twice_d0 = a.d0 * 2
    return (
        UnreducedBigInt3(
        d0=a.d0 * a.d0 + (a.d1 * a.d2) * (2 * 4 * SECP_REM),
        d1=twice_d0 * a.d1 + (a.d2 * a.d2) * (4 * SECP_REM),
        d2=twice_d0 * a.d2 + a.d1 * a.d1))
end

# Verifies that the given unreduced value is equal to zero modulo the secp256k1 prime.
# Completeness assumption: val's limbs are in the range (-2**210.99, 2**210.99).
# Soundness assumption: val's limbs are in the range (-2**250, 2**250).
func verify_zero{range_check_ptr}(val : UnreducedBigInt3):
    let q = [ap]
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import SECP_P
        q, r = divmod(pack(ids.val, PRIME), SECP_P)
        assert r == 0, f"verify_zero: Invalid input {ids.val.d0, ids.val.d1, ids.val.d2}."
        ids.q = q % PRIME
    %}
    let q_biased = [ap + 1]
    q_biased = q + 2 ** 127; ap++
    [range_check_ptr] = q_biased; ap++

    tempvar r1 = (val.d0 + q * SECP_REM) / BASE
    assert [range_check_ptr + 1] = r1 + 2 ** 127
    # This implies r1 * BASE = val.d0 + q * SECP_REM (as integers).

    tempvar r2 = (val.d1 + r1) / BASE
    assert [range_check_ptr + 2] = r2 + 2 ** 127
    # This implies r2 * BASE = val.d1 + r1 (as integers).
    # Therefore, r2 * BASE**2 = val.d1 * BASE + r1 * BASE.

    assert val.d2 = q * (BASE / 4) - r2
    # This implies q * BASE / 4 = val.d2 + r2 (as integers).
    # Therefore,
    #   q * BASE**3 / 4 = val.d2 * BASE**2 + r2 * BASE ** 2 =
    #   val.d2 * BASE**2 + val.d1 * BASE + r1 * BASE =
    #   val.d2 * BASE**2 + val.d1 * BASE + val.d0 + q * SECP_REM =
    #   val + q * SECP_REM.
    # Hence, val = q * (BASE**3 / 4 - SECP_REM) = q * (2**256 - SECP_REM).

    let range_check_ptr = range_check_ptr + 3
    return ()
end

# Returns 1 if x == 0 (mod secp256k1_prime), and 0 otherwise.
func is_zero{range_check_ptr}(x : BigInt3) -> (res : felt):
    %{
        from starkware.cairo.common.cairo_secp.secp_utils import SECP_P, pack
        x = pack(ids.x, PRIME) % SECP_P
    %}
    %{ memory[ap] = int(x == 0) %}
    tempvar x_is_zero
    if x_is_zero != 0:
        verify_zero(UnreducedBigInt3(d0=x.d0, d1=x.d1, d2=x.d2))
        return (res=1)
    end

    %{
        from starkware.cairo.common.cairo_secp.secp_utils import SECP_P
        from starkware.python.math_utils import div_mod

        value = x_inv = div_mod(1, x, SECP_P)
    %}
    let (x_inv) = nondet_bigint3()
    let (x_x_inv) = unreduced_mul(x, x_inv)

    # Check that x * x_inv = 1 to verify that x != 0.
    verify_zero(UnreducedBigInt3(
        d0=x_x_inv.d0 - 1,
        d1=x_x_inv.d1,
        d2=x_x_inv.d2))
    return (res=0)
end
