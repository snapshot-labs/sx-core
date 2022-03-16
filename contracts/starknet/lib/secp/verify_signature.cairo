%lang starknet

from contracts.starknet.lib.secp.secp import verify_ecdsa
from contracts.starknet.lib.secp.secp_ec import EcPoint
from contracts.starknet.lib.secp.bigint import BASE, BigInt3

@external
func verify_signature{range_check_ptr}(
        public_key_pt : EcPoint, msg_hash : BigInt3, r : BigInt3, s : BigInt3):

    # Need to verify soundness of public key pt
    # Need to verify limbs of public_key_pt, msg_hash, r, s

    # Actually verify the signature
    verify_ecdsa(public_key_pt, msg_hash, r, s)

    return ()
end