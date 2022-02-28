# %lang starknet
# %builtins pedersen range_check ecdsa bitwise
# 
# struct Keccak256Hash:
    # member word_1 : felt
    # member word_2 : felt
    # member word_3 : felt
    # member word_4 : felt
# end
# 
# @external
# func keccak_interface{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(msg_len: felt, msg: felt*) -> (hash: Keccak256Hash):
    # alloc_locals
# 
    # let (local keccak_ptr : felt*) = alloc()
    # let keccak_ptr_start = keccak_ptr
# 
    # let (hashed_msg) = keccak256{keccak_ptr=keccak_ptr}(msg, msg_len)
# 
    # local hash: Keccak256Hash = Keccak256Hash(
        # word_1=hashed_msg[0],
        # word_2=hashed_msg[1],
        # word_3=hashed_msg[2],
        # word_4=hashed_msg[3]
    # )
# 
    # return (hash=hash)
# end
# 
# @external
# func add_one(input: felt) -> (res: felt):
    # return (res=(input + 1))
# end

# @external
# func verify_eip712_signature{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(msg_len: felt, msg: felt*, address: Address) -> (valid: felt):
#     let (local keccak_ptr : felt*) = alloc()
#     let keccak_ptr_start = keccak_ptr

#     let (hashed_msg) = keccak256{keccak_ptr=keccak_ptr}(msg, msg_len)

#     local hash: Keccak256Hash = Keccak256Hash(
#         word_1=keccak_hash[0],
#         word_2=keccak_hash[1],
#         word_3=keccak_hash[2],
#         word_4=keccak_hash[3]
#     )

#     return (valid=1)
# end