/* eslint-disable  @typescript-eslint/ban-types */

import Common, { Chain, Hardfork } from '@ethereumjs/common';
import { bufferToHex } from 'ethereumjs-util';
import blockFromRpc from '@ethereumjs/block/dist/from-rpc';
import { IntsSequence } from './types';
import { hexToBytes, assert } from './helpers';

export interface ProcessBlockInputs {
  blockNumber: number;
  blockOptions: number;
  headerInts: IntsSequence;
}

/**
 * Produces the input data for the process_block function in Fossil
 * @param block Block object from RPC call
 * @param chain EVM chain identifier
 * @param hardfork Hardfork identifier
 * @returns ProcessBlockInputs object
 */
export function getProcessBlockInputs(
  block: any,
  chain: Chain = Chain.Mainnet,
  hardfork: Hardfork = Hardfork.London
): ProcessBlockInputs {
  block.difficulty = '0x' + BigInt(block.difficulty).toString(16);
  block.totalDifficulty = '0x' + BigInt(block.totalDifficulty).toString(16);
  const common = new Common({ chain: chain, hardfork: hardfork });
  const header = blockFromRpc(block, [], { common }).header;
  const headerRlp = `0x${header.serialize().toString('hex')}`;
  

  const headerInts = IntsSequence.fromBytes(hexToBytes(headerRlp));
  return {
    blockNumber: block.number as number,
    blockOptions: 8 as number,
    headerInts: headerInts as IntsSequence,
  };
}

export interface ProofInputs {
  blockNumber: number;
  accountOptions: number;
  ethAddress: IntsSequence;
  ethAddressFelt: bigint; // Fossil treats eth addresses two different ways for some reason, it will be changed soon but now this works
  accountProofSizesBytes: bigint[];
  accountProofSizesWords: bigint[];
  accountProof: bigint[];
  storageProofs: bigint[][]; // Multiple storage proofs
}

/**
 * Produces the input data for the account and storage proof verification methods in Fossil
 * @param blockNumber Block Number that the proof targets
 * @param proofs Proofs object from RPC call
 * @param encodeParams The encoding function that should be used on the storage proof data
 * @returns ProofInputs object
 */
export function getProofInputs(blockNumber: number, proofs: any): ProofInputs {
  const accountProofArray = proofs.accountProof.map((node: string) =>
    IntsSequence.fromBytes(hexToBytes(node))
  );
  let accountProof: bigint[] = [];
  let accountProofSizesBytes: bigint[] = [];
  let accountProofSizesWords: bigint[] = [];
  for (const node of accountProofArray) {
    accountProof = accountProof.concat(node.values);
    accountProofSizesBytes = accountProofSizesBytes.concat([BigInt(node.bytesLength)]);
    accountProofSizesWords = accountProofSizesWords.concat([BigInt(node.values.length)]);
  }
  const ethAddress = IntsSequence.fromBytes(hexToBytes(proofs.address));
  const ethAddressFelt = BigInt(proofs.address);

  const storageProofs = [];
  for (let i = 0; i < proofs.storageProof.length; i++) {
    const slot = IntsSequence.fromBytes(hexToBytes(proofs.storageProof[i].key));
    const storageProofArray = proofs.storageProof[i].proof.map((node: string) =>
      IntsSequence.fromBytes(hexToBytes(node))
    );
    let storageProof: bigint[] = [];
    let storageProofSizesBytes: bigint[] = [];
    let storageProofSizesWords: bigint[] = [];
    for (const node of storageProofArray) {
      storageProof = storageProof.concat(node.values);
      storageProofSizesBytes = storageProofSizesBytes.concat([BigInt(node.bytesLength)]);
      storageProofSizesWords = storageProofSizesWords.concat([BigInt(node.values.length)]);
    }
    const storageProofEncoded = encodeParams(
      slot.values,
      storageProofSizesBytes,
      storageProofSizesWords,
      storageProof
    );
    storageProofs.push(storageProofEncoded);
  }

  return {
    blockNumber: blockNumber as number,
    accountOptions: 15 as number,
    ethAddress: ethAddress as IntsSequence,
    ethAddressFelt: ethAddressFelt as bigint,
    accountProofSizesBytes: accountProofSizesBytes as bigint[],
    accountProofSizesWords: accountProofSizesWords as bigint[],
    accountProof: accountProof as bigint[],
    storageProofs: storageProofs as bigint[][],
  };
}

/**
 * Single slot proof voting strategy parameter array encoding (Inclusive -> Exclusive):
 *
 * Start Index      End Index                             Name                Description
 * 0             -> 4                                   - slot              - Key of the storage slot containing the balance that will be verified
 * 4             -> 5                                   - num_nodes         - number of nodes in the proof
 * 5             -> 5+num_nodes                         - proof_sizes_bytes - Array of the sizes in bytes of each node proof
 * 5+num_nodes   -> 5+2*num_nodes                       - proof_sizes_words - Array of the number of words in each node proof
 * 5+2*num_nodes -> 5+2*num_nodes+sum(proof_size_words) - proofs_concat     - Array of the node proofs
 *
 * @param slot Key of the slot containing the storage value that will be verified
 * @param proof_sizes_bytes Array of the sizes in bytes of each node proof
 * @param proof_sizes_words Array of the number of words in each node proof
 * @param proofs_concat Array of the node proofs
 * @returns Encoded array
 */
export function encodeParams(
  slot: bigint[],
  proof_sizes_bytes: bigint[],
  proof_sizes_words: bigint[],
  proofs_concat: bigint[]
): bigint[] {
  assert(proof_sizes_bytes.length == proof_sizes_words.length, 'Invalid parameters');
  const num_nodes = BigInt(proof_sizes_bytes.length);
  return slot.concat([num_nodes], proof_sizes_bytes, proof_sizes_words, proofs_concat);
}

/**
 * Decoding function for the storage proof data
 * @param params Encoded parameter array
 * @returns Decoded parameters
 */
export function decodeParams(params: bigint[]): [bigint[], bigint[], bigint[], bigint[]] {
  assert(params.length >= 5, 'Invalid parameter array');
  const slot: bigint[] = [params[0], params[1], params[2], params[3]];
  const num_nodes = Number(params[4]);
  const proof_sizes_bytes = params.slice(5, 5 + num_nodes);
  const proof_sizes_words = params.slice(5 + num_nodes, 5 + 2 * num_nodes);
  const proofs_concat = params.slice(5 + 2 * num_nodes);
  const total = proof_sizes_words.reduce(function (x, y) {
    return x + y;
  }, BigInt(0));
  assert(total == BigInt(proofs_concat.length), 'Invalid parameter array');
  return [slot, proof_sizes_bytes, proof_sizes_words, proofs_concat];
}
