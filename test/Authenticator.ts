import { expect } from "chai";
import { starknet } from "hardhat";

describe("Verify EIP712 Signatures", function () {
  this.timeout(600_000); // 30 seconds - recommended if used with starknet-devnet

  /**
   * Assumes there is a file MyContract.cairo whose compilation artifacts have been generated.
   * The contract is assumed to have:
   * - constructor function constructor(initial_balance: felt)
   * - external function increase_balance(amount: felt) -> (res: felt)
   * - view function get_balance() -> (res: felt)
   */ 
//   it("should work for a fresh deployment", async function () {
//     const contractFactory = await starknet.getContractFactory("authenticator");
//     const contract = await contractFactory.deploy({});
//     console.log("Deployed at", contract.address);

//     const { hash: a } = await contract.call("keccak_interface", {msg: ["18446744073709551615"]}); // invoke method by name and pass arguments by name
//     console.log(a)
//     expect(a).to.deep.equal(BigInt(0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470));
//   });

  it("adds one", async function () {
    const contractFactory = await starknet.getContractFactory("authenticator");
    const contract = await contractFactory.deploy({});
    console.log("Deployed at", contract.address);

    const { res: a } = await contract.call("add_one", {input: 1}); // invoke method by name and pass arguments by name
    expect(a).to.deep.equal(BigInt(2));
  });
});