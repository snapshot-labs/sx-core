%lang starknet
%builtins pedersen range_check bitwise

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.cairo.common.math import unsigned_div_rem, assert_nn_le
from starkware.cairo.common.pow import pow

from contracts.starknet.lib.types import EthereumAddress

#Returns a voting power of 1 for every address it is queried with. 
@view
func get_voting_power{
        syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*}(
        block : felt, account_160 : felt, params_len : felt, params : felt*) -> (
        voting_power : Uint256):
    tempvar voting_power : Uint256 = Uint256(1,0)
    return (voting_power)
end



