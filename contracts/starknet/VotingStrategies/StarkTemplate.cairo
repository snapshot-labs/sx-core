%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from contracts.starknet.lib.general_address import Address
from starkware.cairo.common.uint256 import Uint256

#
# Template Voting Strategy
#

@storage_var
func token_address_store() -> (res : felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    token_address : felt
):
    token_address_store.write(token_address)

    return ()
end

@view
func get_voting_power{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr, bitwise_ptr : BitwiseBuiltin*
}(
    timestamp : felt,
    voter_address : Address,
    params_len : felt,
    params : felt*,
    user_params_len : felt,
    user_params : felt*,
) -> (voting_power : Uint256):
    # Perform arbitrary logic here.
    # eg 1 voting power per address
    let voting_power = Uint256(1, 0)

    return (voting_power)
end
