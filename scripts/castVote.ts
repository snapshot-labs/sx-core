import fs, { access } from 'fs';
import fetch from 'cross-fetch';
import { Provider, defaultProvider, json, Contract, Account, ec, hash } from 'starknet';
import { utils } from '@snapshot-labs/sx';
import { ethers } from 'ethers';
import { toBN } from 'starknet/dist/utils/number';

// Using deployment at: deployments/goerli2.json

async function main() {
  global.fetch = fetch;

  const account = new Account(
    defaultProvider,
    process.env.ARGENT_ACCOUNT_ADDRESS!,
    ec.getKeyPair(process.env.ARGENT_PRIVATE_KEY!)
  );
  const spaceAddress = '0x3a4cb1c6e4439e2ce2c43b565e6347f2f334cd3a387e86fb14f7655c9b6704a';
  const voterEthAddress = ethers.Wallet.createRandom().address;
  const proposalId = BigInt(1);
  const choice = utils.choice.Choice.AGAINST;
  const usedVotingStrategies = [
    BigInt('0x4fa559ef60470db4a3717eb2416842fae4e69a7f71f2d6daf9a00e517e3b572'),
  ];
  const userVotingParamsAll = [[]];
  const voteCalldata = utils.encoding.getVoteCalldata(
    voterEthAddress,
    proposalId,
    choice,
    usedVotingStrategies,
    userVotingParamsAll
  );
  const voteCalldataHex = voteCalldata.map((x) => '0x' + x.toString(16));
  const calldata = [
    spaceAddress,
    hash.getSelectorFromName('vote'),
    voteCalldataHex.length,
    ...voteCalldataHex,
  ];

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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
