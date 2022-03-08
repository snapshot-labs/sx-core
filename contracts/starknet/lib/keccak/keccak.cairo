%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.alloc import alloc
from contracts.starknet.lib.keccak.keccak_hash import KeccakHash
from contracts.starknet.lib.keccak.keccak_256 import keccak256

@view
func keccak{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(keccak_input_length: felt, input_len : felt, input : felt*) -> (res: KeccakHash):
    alloc_locals
    let (local keccak_ptr : felt*) = alloc()
    let keccak_ptr_start = keccak_ptr

    let (keccak_hash) = keccak256{keccak_ptr=keccak_ptr}(input, keccak_input_length)

    local hash: KeccakHash = KeccakHash(
        word_1=keccak_hash[0],
        word_2=keccak_hash[1],
        word_3=keccak_hash[2],
        word_4=keccak_hash[3]
    )

    return (hash)
end
