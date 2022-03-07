#!/bin/bash

# This example deploys a contract that verifies a secp256k1 ECDSA signature.

set -ex

cd $(dirname $0)

starknet-compile secp_contract.cairo --output secp_contract_compiled.json \
    --abi secp_contract_abi.json
starknet deploy --contract secp_contract_compiled.json > deploy_output.txt
cat deploy_output.txt
CONTRACT_ADDRESS=$(sed -ne "s|^Contract address: \(0x[0-9a-fA-F]\+\)$|\1|p" deploy_output.txt)
echo "Started contract deployment to address: $CONTRACT_ADDRESS"

starknet invoke --address $CONTRACT_ADDRESS --abi secp_contract_abi.json \
    --function verify_signature \
    --inputs \
        `#public_key_pt` \
        0x35dec240d9f76e20b48b41 0x27fcb378b533f57a6b585 0xbff381888b165f92dd33d \
        0x1711d8fb6fbbf53986b57f 0x2e56f964d38cb8dbdeb30b 0xe4be2a8547d802dc42041 \
        `#msg_hash` \
        0x38a23ca66202c8c2a72277 0x6730e765376ff17ea8385 0xca1ad489ab60ea581e6c1 \
        `#r` \
        0x2e6c77fee73f3ac9be1217 0x3f0c0b121ac1dc3e5c03c6 0xeee3e6f50c576c07d7e4a \
        `#s` \
        0x20a4b46d3c5e24cda81f22 0x967bf895824330d4273d0 0x541e10c21560da25ada4c
