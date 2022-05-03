import { stark } from 'starknet';
import { SplitUint256, FOR } from './shared/types';
import { strToShortStringArr } from '@snapshot-labs/sx';
import { expect } from 'chai';
import { starknet } from 'hardhat';
import {
  VITALIK_ADDRESS,
} from './shared/setup';
import { StarknetContract } from 'hardhat/types';

const { getSelectorFromName } = stark;

describe('Whitelist testing', () => {
  let whitelistStrat: StarknetContract;
  let emptyStrat: StarknetContract;
  let repeatStrat: StarknetContract;
  let bigStrat: StarknetContract;
  const ADDRR_1 = BigInt("11111");
  const ADDRR_2 = BigInt("22222");
  const ADDRR_3 = BigInt("33333");
  const ADDRR_4 = BigInt("44444");

  before(async function () {
    const whitelistFactory = await starknet.getContractFactory(
      './contracts/starknet/strategies/whitelist.cairo'
    );
    whitelistStrat = await whitelistFactory.deploy({_whitelist: [VITALIK_ADDRESS]});
    emptyStrat = await whitelistFactory.deploy({_whitelist: []});
    repeatStrat = await whitelistFactory.deploy({_whitelist: [VITALIK_ADDRESS, VITALIK_ADDRESS, ADDRR_1]});
    bigStrat = await whitelistFactory.deploy({_whitelist: [ADDRR_1, ADDRR_2, ADDRR_3, ADDRR_4]});
  });

  it('returns 0 for non-whitelisted addresses', async () => {
      const random_address = BigInt(0x12345);
      let {voting_power} = await whitelistStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: random_address}, params: []});

      let vp = SplitUint256.fromObj(voting_power);
      let expected = SplitUint256.fromUint(BigInt(0));
      expect(vp).to.deep.equal(expected);
  });

  it('returns 1 for whitelisted addresses', async () => {
      const random_address = BigInt(0x12345);
      let {voting_power} = await whitelistStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: VITALIK_ADDRESS}, params: []});

      let vp = SplitUint256.fromObj(voting_power);
      let expected = SplitUint256.fromUint(BigInt(1));
      expect(vp).to.deep.equal(expected);
  });

  it('returns 0 for an empty whitelist', async () => {
      let {voting_power} = await emptyStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: VITALIK_ADDRESS}, params: []});

      let vp = SplitUint256.fromObj(voting_power);
      let expected = SplitUint256.fromUint(BigInt(0));
      expect(vp).to.deep.equal(expected);
  });

  it('returns 1 even if address is repeated', async () => {
      let {voting_power} = await repeatStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: VITALIK_ADDRESS}, params: []});

      let vp = SplitUint256.fromObj(voting_power);
      let expected = SplitUint256.fromUint(BigInt(1));
      expect(vp).to.deep.equal(expected);
  });

  it('returns 1 if address is NOT repeated', async () => {
      let {voting_power} = await bigStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: ADDRR_1}, params: []});

      let vp = SplitUint256.fromObj(voting_power);
      let expected = SplitUint256.fromUint(BigInt(1));
      expect(vp).to.deep.equal(expected);
  });

  it('returns 1 even for everyone in the list', async () => {
      let voting_power1 = await bigStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: ADDRR_1}, params: []});
      let voting_power2 = await bigStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: ADDRR_2}, params: []});
      let voting_power3 = await bigStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: ADDRR_3}, params: []});
      let voting_power4 = await bigStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: ADDRR_4}, params: []});

      const results = [voting_power1, voting_power2, voting_power3, voting_power4];
      const expected = SplitUint256.fromUint(BigInt(1));
      for (const {voting_power} of results) {
        let vp = SplitUint256.fromObj(voting_power);
        expect(vp).to.deep.equal(expected);
      }
  });

  it('returns 0 if address is NOT in the big list', async () => {
      let {voting_power} = await bigStrat.call("get_voting_power", {timestamp: BigInt(0), address: {value: VITALIK_ADDRESS}, params: []});

      let vp = SplitUint256.fromObj(voting_power);
      let expected = SplitUint256.fromUint(BigInt(0));
      expect(vp).to.deep.equal(expected);
  });
});