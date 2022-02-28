import { task } from 'hardhat/config';
import { HardhatUserConfig } from 'hardhat/types';
import '@shardlabs/starknet-hardhat-plugin';
import '@nomiclabs/hardhat-ethers';

task('accounts', 'Prints the list of accounts', async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(await account.getAddress());
  }
});

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.6',
    settings: {
      optimizer: {
        enabled: true,
        runs: 10,
      },
    },
  },
  starknet: {
    // dockerizedVersion: "0.7.0",
    venv: "active",
    network: "starknetDevnet",
  },
  networks: {
    ropsten: {
      url: process.env.ROPSTEN_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    devnet: {
      url: 'http://localhost:8545',
    },
    starknetDevnet: {
      url: 'http://localhost:8000/',
    },
  },
};

export default config;
