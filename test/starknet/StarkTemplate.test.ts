import { StarknetContract } from 'hardhat/types/runtime';
import { expect } from 'chai';
import { starknet, ethers } from 'hardhat';
import { utils } from '@snapshot-labs/sx';

async function setup() {
  const StarkTemplateVotingStrategyFactory = await starknet.getContractFactory(
    './contracts/starknet/VotingStrategies/StarkTemplate.cairo'
  );
  const StarkTemplateVotingStrategy = await StarkTemplateVotingStrategyFactory.deploy({
    token_address: '0x0000000000000000000000000000000000000000',
  });
  return {
    StarkTemplateVotingStrategy: StarkTemplateVotingStrategy as StarknetContract,
  };
}

describe('Snapshot X Vanilla Voting Strategy:', () => {
  it('The voting strategy should return a voting power of 1', async () => {
    const { StarkTemplateVotingStrategy } = await setup();
    const { voting_power: vp } = await StarkTemplateVotingStrategy.call('get_voting_power', {
      timestamp: 1,
      voter_address: { value: BigInt(ethers.Wallet.createRandom().address) },
      params: [],
      user_params: [],
    });
    expect(new utils.splitUint256.SplitUint256(vp.low, vp.high)).to.deep.equal(
      utils.splitUint256.SplitUint256.fromUint(BigInt(1))
    );
  }).timeout(600000);
});
