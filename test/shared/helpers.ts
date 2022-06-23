import { ethers } from 'hardhat';
import { SplitUint256, Choice } from './types';
import { expect } from 'chai';
import { BigNumber } from 'ethers';
import { computeHashOnElements } from 'starknet/dist/utils/hash';
import { toBN } from 'starknet/dist/utils/number';
import { EIP712_TYPES } from './safeUtils';
import { _TypedDataEncoder } from '@ethersproject/hash';

export function assert(condition: boolean, message = 'Assertion Failed'): boolean {
  if (!condition) {
    throw message;
  }
  return condition;
}

export function hexToBytes(hex: string): number[] {
  const bytes = [];
  for (let c = 2; c < hex.length; c += 2) bytes.push(parseInt(hex.substring(c, c + 2), 16));
  return bytes;
}

export function bytesToHex(bytes: number[] | Uint8Array): string {
  const body = Array.from(bytes, function (byte) {
    return ('0' + (byte & 0xff).toString(16)).slice(-2);
  }).join('');
  return '0x' + body;
}

/**
 * Strip leading zeros from a hex string
 * @param address a hex string representation of an address
 * @returns An adapted hex string representation of the address
 */
export function stripAddress(address: string): string {
  return '0x' + BigInt(address).toString(16);
}

/**
 * Convert 4 64 bit words to a 256 bit word
 * @param word1 A 64 bit word
 * @param word2 A 64 bit word
 * @param word3 A 64 bit word
 * @param word4 A 64 bit word
 * @returns A 256 bit word
export function wordsToUint(word1: bigint, word2: bigint, word3: bigint, word4: bigint): bigint {
  const s3 = BigInt(2 ** 64);
  const s2 = BigInt(2 ** 128);
  const s1 = BigInt(2 ** 192);
  return word4 + word3 * s3 + word2 * s2 + word1 * s1;
}

/**
 * Converts a 256 bit word to a tuple of 4 64 bit words
 * @param uint A 256 bit word
 * @returns A tuple of 4 64 bit words
 */
export function uintToWords(
  uint: bigint
): [word1: bigint, word2: bigint, word3: bigint, word4: bigint] {
  assert(0 <= uint && uint < 2 ** 256, 'number out of range');
  const word4 = uint & ((BigInt(1) << BigInt(64)) - BigInt(1));
  const word3 = (uint & ((BigInt(1) << BigInt(128)) - (BigInt(1) << BigInt(64)))) >> BigInt(64);
  const word2 = (uint & ((BigInt(1) << BigInt(192)) - (BigInt(1) << BigInt(128)))) >> BigInt(128);
  const word1 = uint >> BigInt(192);
  return [word1, word2, word3, word4];
}

/**
 * Computes the Pedersen hash of a execution payload for StarkNet
 * This can be used to produce the input for calling the commit method in the StarkNet Commit contract.
 * @param target the target address of the execution
 * @param selector the selector for the method at address target one wants to execute
 * @param calldata the payload for the method at address target one wants to execute
 * @returns A Pedersen hash of the data as a Big Int
 */
export function getCommit(target: bigint, selector: bigint, calldata: bigint[]): bigint {
  const targetBigNum = toBN('0x' + target.toString(16));
  const selectorBigNum = toBN('0x' + selector.toString(16));
  const calldataBigNum = calldata.map((x) => toBN('0x' + x.toString(16)));
  return BigInt(computeHashOnElements([targetBigNum, selectorBigNum, ...calldataBigNum]));
}

export interface Transaction {
  to: string;
  value: string | number | BigNumber;
  data: string;
  operation: number;
  nonce: number;
}

/**
 * Computes an  execution hash and a set of transaction hashes for a proposal
 * @param verifyingContract The verifying l1 contract
 * @param txs Array of transactions
 * @returns An array of transaction hashes and an overall keccak hash of those hashes
 */
export function createExecutionHash(
  txs: Transaction[],
  verifyingContract: string,
  chainId: number
): {
  executionHash: string;
  txHashes: string[];
} {
  const domain = {
    chainId: chainId,
    verifyingContract: verifyingContract,
  };
  const txHashes = txs.map((tx) => _TypedDataEncoder.hash(domain, EIP712_TYPES, tx));
  const abiCoder = new ethers.utils.AbiCoder();
  const executionHash = ethers.utils.keccak256(abiCoder.encode(['bytes32[]'], [txHashes]));
  return {
    executionHash: executionHash,
    txHashes: txHashes,
  };
}

/**
 * Currently there is no way to pass struct types with pointers in calldata, so we must pass the 2d array as a flat array and then reconstruct the type.
 * The structure of the flat array that is output from this function is as follows:
 * flat_array[0] = num_arrays
 * flat_array[1:1+num_arrays] = offsets
 * flat_array[1+num_arrays:] = elements
 * @param array2D The 2d array to flatten
 * @returns The flattened array
 */
export function flatten2DArray(array2D: bigint[][]): bigint[] {
  const flatArray: bigint[] = [];
  const num_arrays = BigInt(array2D.length);
  flatArray.push(num_arrays);
  let offset = BigInt(0);
  flatArray.push(offset);
  for (let i = 0; i < num_arrays - BigInt(1); i++) {
    offset += BigInt(array2D[i].length);
    flatArray.push(offset);
  }
  const elements = array2D.reduce((accumulator, value) => accumulator.concat(value), []);
  return flatArray.concat(elements);
}

/**
 * Generates a calldata array for creating a proposal through an authenticator
 * @param proposerAddress The address of the proposal creator
 * @param executionHash The hash of the proposal execution
 * @param metadataUri The URI address of the proposal
 * @param executorAddress The address of the execution strategy that is used in the proposal
 * @param usedVotingStrategies An array of the voting strategy addresses that are used in the proposal
 * @param usedVotingStrategyParams An array of arrays containing the parameters corresponding to the voting strategies used
 * @param executionParams An array of the execution parameters used
 * @returns Calldata array
 */
export function getProposeCalldata(
  proposerAddress: string,
  executionHash: string,
  metadataUri: bigint[],
  executorAddress: bigint,
  usedVotingStrategies: bigint[],
  usedVotingStrategyParams: bigint[][],
  executionParams: bigint[]
): bigint[] {
  const executionHashUint256 = SplitUint256.fromHex(executionHash);
  const usedVotingStrategyParamsFlat = flatten2DArray(usedVotingStrategyParams);
  return [
    BigInt(proposerAddress),
    executionHashUint256.low,
    executionHashUint256.high,
    BigInt(metadataUri.length),
    ...metadataUri,
    executorAddress,
    BigInt(usedVotingStrategies.length),
    ...usedVotingStrategies,
    BigInt(usedVotingStrategyParamsFlat.length),
    ...usedVotingStrategyParamsFlat,
    BigInt(executionParams.length),
    ...executionParams,
  ];
}

/**
 * Generates a calldata array for casting a vote through an authenticator
 * @param voterAddress The address of the proposal creator
 * @param proposalID The ID of the proposal
 * @param choice The choice of the voter (For, Against, Abstain)
 * @param usedVotingStrategies An array of the voting strategy addresses that are used in the proposal
 * @param usedVotingStrategyParams An array of arrays containing the parameters corresponding to the voting strategies used
 * @returns Calldata array
 */
export function getVoteCalldata(
  voterAddress: string,
  proposalID: bigint,
  choice: Choice,
  usedVotingStrategies: bigint[],
  usedVotingStrategyParams: bigint[][]
): bigint[] {
  const usedVotingStrategyParamsFlat = flatten2DArray(usedVotingStrategyParams);
  return [
    BigInt(voterAddress),
    proposalID,
    BigInt(choice),
    BigInt(usedVotingStrategies.length),
    ...usedVotingStrategies,
    BigInt(usedVotingStrategyParamsFlat.length),
    ...usedVotingStrategyParamsFlat,
  ];
}
