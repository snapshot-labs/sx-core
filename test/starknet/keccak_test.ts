import { StarknetContract } from 'hardhat/types/runtime';
import { starknet } from 'hardhat';
import { stark } from 'starknet';
import web3 from 'web3'
import { BigNumber } from 'ethers';
import { bnToUint256 } from 'starknet/dist/utils/uint256';
import { toBN } from 'starknet/dist/utils/number';

async function setup() {
  const keccakFactory = await starknet.getContractFactory(
    './contracts/starknet/lib/keccak/keccak.cairo'
  );
  const keccak = await keccakFactory.deploy();
  return {
    keccak: keccak as StarknetContract,
  };
}

describe('Keccak:', () => {
  it('Vanilla keccak', async () => {
    const { keccak } = await setup();
// func keccak{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(keccak_input_length: felt, input_len : felt, input : felt*) -> (res: KeccakHash):
    const keccak_input = [BigInt(0x41)];
    const keccak_string_input = "A";

    console.log(keccak_input);
    const kecca_input_length = keccak_string_input.length;

    const hash = web3.utils.keccak256(keccak_string_input);
    console.log("hash: ", hash)

    const { res } = await keccak.call("keccak", {
      keccak_input_length: kecca_input_length,
      input: keccak_input,
    });
    console.log("res: ", res);

    const recovered4 = res.word_1.toString(16) + res.word_2.toString(16) + res.word_3.toString(16) + res.word_4.toString(16);
    console.log("toString: ", recovered4);
  }).timeout(60000);
});
