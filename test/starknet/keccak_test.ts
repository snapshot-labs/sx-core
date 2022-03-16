import { StarknetContract } from 'hardhat/types/runtime';
import { starknet } from 'hardhat';
import { stark } from 'starknet';
import web3 from 'web3'
import { BigNumber } from 'ethers';
import { bnToUint256 } from 'starknet/dist/utils/uint256';
import { toBN } from 'starknet/dist/utils/number';
import { u256ToBigInt3 } from './shared/split';
var Wallet = require('ethereumjs-wallet');
var EthUtil = require('ethereumjs-util');

async function setup() {
  const keccakFactory = await starknet.getContractFactory(
    './contracts/starknet/lib/keccak/keccak.cairo'
  );
  const keccak = await keccakFactory.deploy();
  return {
    keccak: keccak as StarknetContract,
  };
}

async function setupVerifContract() {
  const verifFactory = await starknet.getContractFactory(
    './contracts/starknet/lib/secp/verify_signature.cairo'
  );
  const verifContract = await verifFactory.deploy();
  return {
    verifContract: verifContract as StarknetContract,
  };
}

// describe('Keccak:', () => {
//   it('Vanilla keccak', async () => {
//     const { keccak } = await setup();
// // func keccak{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(keccak_input_length: felt, input_len : felt, input : felt*) -> (res: KeccakHash):
//     const keccak_input = [BigInt(0x41)];
//     const keccak_string_input = "A";

//     console.log(keccak_input);
//     const kecca_input_length = keccak_string_input.length;

//     const hash = web3.utils.keccak256(keccak_string_input);
//     console.log("hash: ", hash)

//     const { res } = await keccak.call("keccak", {
//       keccak_input_length: kecca_input_length,
//       input: keccak_input,
//     });
//     console.log("res: ", res);

//     const recovered4 = res.word_1.toString(16) + res.word_2.toString(16) + res.word_3.toString(16) + res.word_4.toString(16);
//     console.log("toString: ", recovered4);
//   }).timeout(60000);
// });

function getRekt() {
    // Get a wallet instance from a private key
    const privateKeyBuffer = EthUtil.toBuffer('0x61ce8b95ca5fd6f55cd97ac60817777bdf64f1670e903758ce53efc32c3dffeb');
    const wallet = Wallet.fromPrivateKey(privateKeyBuffer);

    // Get a public key
    const publicKey = wallet.getPublicKeyString();                                                                                                                                                                                                                                                               
    console.log(publicKey);
}


describe('712:', () => {
  it('Vanilla 712', async () => {
    const { verifContract } = await setupVerifContract();
    const publicKeyPt = {x: [BigInt(1), BigInt(2), BigInt(3)], y: [BigInt(4), BigInt(5), BigInt(6)]};
    const msgHash = u256ToBigInt3("0x680ffed756997a30b00925b6b087d2239430495cadfd71b388bd3df0db520c69");
    const r = u256ToBigInt3("0x773d1ffda84204208596a72c884b238f78ada58965ebfacd81aab3e29d1cce86");
    const s = u256ToBigInt3("0x27c7134482ed99c31dfe1047ca7c9b167607dfa3a0f67ce299b57c3a771d7e9d");
    await verifContract.invoke("verify_signature", {
      public_key_pt: publicKeyPt,
      msg_hash: msgHash,
      r,
      s
    });
  }).timeout(60000);
});