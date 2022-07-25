import fs, { access } from 'fs';
import fetch from 'cross-fetch';
import { Provider, defaultProvider, json, Contract, Account, ec, hash } from 'starknet';
import { utils } from '@snapshot-labs/sx';
import { ethers } from 'ethers';
import { toBN } from 'starknet/dist/utils/number';

// Using deployment at: deployments/goerli2.json

async function main() {
  global.fetch = fetch;

  const starkKeyPair = ec.getKeyPair(
    '637357425248906491734798339821267946913367255989714880095234737256366305691'
  );
  const account = new Account(
    defaultProvider,
    '0x0764c647e4c5f6e81c5baa1769b4554e44851a7b6319791fc6db9e25a32148bb',
    starkKeyPair
  );

  // Generating propose calldata:
  const metadataUri = utils.strings.strToShortStringArr(
    'Hello and welcome to Snapshot X. This is the future of governance.'
  );
  const proposerEthAddress = ethers.Wallet.createRandom().address;
  const spaceAddress = '0x3a4cb1c6e4439e2ce2c43b565e6347f2f334cd3a387e86fb14f7655c9b6704a';
  const usedVotingStrategies = [
    BigInt('0x4fa559ef60470db4a3717eb2416842fae4e69a7f71f2d6daf9a00e517e3b572'),
  ];
  const userVotingParamsAll = [[]];
  const executionStrategy = BigInt(
    '0x622b6f2e8fa0de8aabb3bff5f2c5d46d4326d51589d5c068931bd5967747eed'
  );
  const executionParams: bigint[] = [];
  const proposeCalldata = utils.encoding.getProposeCalldata(
    proposerEthAddress,
    metadataUri,
    executionStrategy,
    usedVotingStrategies,
    userVotingParamsAll,
    executionParams
  );
  const proposeCalldataHex = proposeCalldata.map((x) => '0x' + x.toString(16));
  const calldata = [
    spaceAddress,
    hash.getSelectorFromName('propose'),
    proposeCalldataHex.length,
    ...proposeCalldataHex,
  ];

  // Executing propose tx via the vanilla authenticator
  const { transaction_hash: txHash } = await account.execute(
    {
      contractAddress: '0x74edaa556d63d5f06e9b633b887a6b01159bb01c9b87cc3f27827af59239c28',
      entrypoint: 'authenticate',
      calldata: calldata,
    },
    undefined,
    { maxFee: '857400005301800' }
  );
  console.log(txHash);

  // const { transaction_hash: txHash } = await account.execute(
  //   {
  //     contractAddress: '0x26ff4b2c18c627853e942bc99ad9d03c4872ddf3908dbafce22a3153976b81b',
  //     entrypoint: 'update_quorum',
  //     calldata: ['0x2'],
  //   },
  //   undefined,
  //   { maxFee: '857400005301800' }
  // );
  // console.log(txHash);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
