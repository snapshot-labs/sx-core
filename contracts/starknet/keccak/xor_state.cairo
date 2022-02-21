from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.bitwise import bitwise_xor
from starkware.cairo.common.alloc import alloc

# XORs the state with values
func state_xor{bitwise_ptr : BitwiseBuiltin*}(state : felt*, values : felt*) -> (xored_values : felt*):
    alloc_locals
    let (local output : felt*) = alloc()

    assert bitwise_ptr[0].x = state[0]
    assert bitwise_ptr[1].x = state[1]
    assert bitwise_ptr[2].x = state[2]
    assert bitwise_ptr[3].x = state[3]
    assert bitwise_ptr[4].x = state[4]
    assert bitwise_ptr[5].x = state[5]
    assert bitwise_ptr[6].x = state[6]
    assert bitwise_ptr[7].x = state[7]
    assert bitwise_ptr[8].x = state[8]
    assert bitwise_ptr[9].x = state[9]
    assert bitwise_ptr[10].x = state[10]
    assert bitwise_ptr[11].x = state[11]
    assert bitwise_ptr[12].x = state[12]
    assert bitwise_ptr[13].x = state[13]
    assert bitwise_ptr[14].x = state[14]
    assert bitwise_ptr[15].x = state[15]
    assert bitwise_ptr[16].x = state[16]
    assert bitwise_ptr[17].x = state[17]
    assert bitwise_ptr[18].x = state[18]
    assert bitwise_ptr[19].x = state[19]
    assert bitwise_ptr[20].x = state[20]
    assert bitwise_ptr[21].x = state[21]
    assert bitwise_ptr[22].x = state[22]
    assert bitwise_ptr[23].x = state[23]
    assert bitwise_ptr[24].x = state[24]

    assert bitwise_ptr[0].y = values[0]
    assert bitwise_ptr[1].y = values[1]
    assert bitwise_ptr[2].y = values[2]
    assert bitwise_ptr[3].y = values[3]
    assert bitwise_ptr[4].y = values[4]
    assert bitwise_ptr[5].y = values[5]
    assert bitwise_ptr[6].y = values[6]
    assert bitwise_ptr[7].y = values[7]
    assert bitwise_ptr[8].y = values[8]
    assert bitwise_ptr[9].y = values[9]
    assert bitwise_ptr[10].y = values[10]
    assert bitwise_ptr[11].y = values[11]
    assert bitwise_ptr[12].y = values[12]
    assert bitwise_ptr[13].y = values[13]
    assert bitwise_ptr[14].y = values[14]
    assert bitwise_ptr[15].y = values[15]
    assert bitwise_ptr[16].y = values[16]
    assert bitwise_ptr[17].y = values[17]
    assert bitwise_ptr[18].y = values[18]
    assert bitwise_ptr[19].y = values[19]
    assert bitwise_ptr[20].y = values[20]
    assert bitwise_ptr[21].y = values[21]
    assert bitwise_ptr[22].y = values[22]
    assert bitwise_ptr[23].y = values[23]
    assert bitwise_ptr[24].y = values[24]

    assert output[0] = bitwise_ptr[0].x_xor_y
    assert output[1] = bitwise_ptr[1].x_xor_y
    assert output[2] = bitwise_ptr[2].x_xor_y
    assert output[3] = bitwise_ptr[3].x_xor_y
    assert output[4] = bitwise_ptr[4].x_xor_y
    assert output[5] = bitwise_ptr[5].x_xor_y
    assert output[6] = bitwise_ptr[6].x_xor_y
    assert output[7] = bitwise_ptr[7].x_xor_y
    assert output[8] = bitwise_ptr[8].x_xor_y
    assert output[9] = bitwise_ptr[9].x_xor_y
    assert output[10] = bitwise_ptr[10].x_xor_y
    assert output[11] = bitwise_ptr[11].x_xor_y
    assert output[12] = bitwise_ptr[12].x_xor_y
    assert output[13] = bitwise_ptr[13].x_xor_y
    assert output[14] = bitwise_ptr[14].x_xor_y
    assert output[15] = bitwise_ptr[15].x_xor_y
    assert output[16] = bitwise_ptr[16].x_xor_y
    assert output[17] = bitwise_ptr[17].x_xor_y
    assert output[18] = bitwise_ptr[18].x_xor_y
    assert output[19] = bitwise_ptr[19].x_xor_y
    assert output[20] = bitwise_ptr[20].x_xor_y
    assert output[21] = bitwise_ptr[21].x_xor_y
    assert output[22] = bitwise_ptr[22].x_xor_y
    assert output[23] = bitwise_ptr[23].x_xor_y
    assert output[24] = bitwise_ptr[24].x_xor_y

    let bitwise_ptr = bitwise_ptr + 25 * BitwiseBuiltin.SIZE
    return (output)
end

# Masks the 8 rightmost bytes on each felt
# Everything to the left is considered garbage
func mask_garbage{bitwise_ptr : BitwiseBuiltin*}(input : felt*) -> (output : felt*):
    alloc_locals
    let (local output : felt*) = alloc()

    assert bitwise_ptr[0].x = input[0]
    assert bitwise_ptr[1].x = input[1]
    assert bitwise_ptr[2].x = input[2]
    assert bitwise_ptr[3].x = input[3]
    assert bitwise_ptr[4].x = input[4]
    assert bitwise_ptr[5].x = input[5]
    assert bitwise_ptr[6].x = input[6]
    assert bitwise_ptr[7].x = input[7]
    assert bitwise_ptr[8].x = input[8]
    assert bitwise_ptr[9].x = input[9]
    assert bitwise_ptr[10].x = input[10]
    assert bitwise_ptr[11].x = input[11]
    assert bitwise_ptr[12].x = input[12]
    assert bitwise_ptr[13].x = input[13]
    assert bitwise_ptr[14].x = input[14]
    assert bitwise_ptr[15].x = input[15]
    assert bitwise_ptr[16].x = input[16]
    assert bitwise_ptr[17].x = input[17]
    assert bitwise_ptr[18].x = input[18]
    assert bitwise_ptr[19].x = input[19]
    assert bitwise_ptr[20].x = input[20]
    assert bitwise_ptr[21].x = input[21]
    assert bitwise_ptr[22].x = input[22]
    assert bitwise_ptr[23].x = input[23]
    assert bitwise_ptr[24].x = input[24]

    # e4 4c bb 43 3e b6 6a b9
    # we need 64bits
    # 2^64-1
    let mask = 2 ** 64 - 1

    assert bitwise_ptr[0].y = mask
    assert bitwise_ptr[1].y = mask
    assert bitwise_ptr[2].y = mask
    assert bitwise_ptr[3].y = mask
    assert bitwise_ptr[4].y = mask
    assert bitwise_ptr[5].y = mask
    assert bitwise_ptr[6].y = mask
    assert bitwise_ptr[7].y = mask
    assert bitwise_ptr[8].y = mask
    assert bitwise_ptr[9].y = mask
    assert bitwise_ptr[10].y = mask
    assert bitwise_ptr[11].y = mask
    assert bitwise_ptr[12].y = mask
    assert bitwise_ptr[13].y = mask
    assert bitwise_ptr[14].y = mask
    assert bitwise_ptr[15].y = mask
    assert bitwise_ptr[16].y = mask
    assert bitwise_ptr[17].y = mask
    assert bitwise_ptr[18].y = mask
    assert bitwise_ptr[19].y = mask
    assert bitwise_ptr[20].y = mask
    assert bitwise_ptr[21].y = mask
    assert bitwise_ptr[22].y = mask
    assert bitwise_ptr[23].y = mask
    assert bitwise_ptr[24].y = mask

    assert output[0] = bitwise_ptr[0].x_and_y
    assert output[1] = bitwise_ptr[1].x_and_y
    assert output[2] = bitwise_ptr[2].x_and_y
    assert output[3] = bitwise_ptr[3].x_and_y
    assert output[4] = bitwise_ptr[4].x_and_y
    assert output[5] = bitwise_ptr[5].x_and_y
    assert output[6] = bitwise_ptr[6].x_and_y
    assert output[7] = bitwise_ptr[7].x_and_y
    assert output[8] = bitwise_ptr[8].x_and_y
    assert output[9] = bitwise_ptr[9].x_and_y
    assert output[10] = bitwise_ptr[10].x_and_y
    assert output[11] = bitwise_ptr[11].x_and_y
    assert output[12] = bitwise_ptr[12].x_and_y
    assert output[13] = bitwise_ptr[13].x_and_y
    assert output[14] = bitwise_ptr[14].x_and_y
    assert output[15] = bitwise_ptr[15].x_and_y
    assert output[16] = bitwise_ptr[16].x_and_y
    assert output[17] = bitwise_ptr[17].x_and_y
    assert output[18] = bitwise_ptr[18].x_and_y
    assert output[19] = bitwise_ptr[19].x_and_y
    assert output[20] = bitwise_ptr[20].x_and_y
    assert output[21] = bitwise_ptr[21].x_and_y
    assert output[22] = bitwise_ptr[22].x_and_y
    assert output[23] = bitwise_ptr[23].x_and_y
    assert output[24] = bitwise_ptr[24].x_and_y

    let bitwise_ptr = bitwise_ptr + 25 * BitwiseBuiltin.SIZE
    return (output)
end