%lang starknet

from contracts.starknet.lib.types import EthAddress
from starkware.cairo.common.uint256 import Uint256

# TODO: use L1Address instead of felt
@contract_interface
namespace IVotingStrategy:
    func get_voting_power(address : EthAddress, at : felt, params_len : felt, params : felt*) -> (
            voting_power : Uint256):
    end
end