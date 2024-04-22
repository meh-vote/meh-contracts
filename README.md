# Meh

## run
```shell
npx hardhat node
npx hardhat compile
npx hardhat test
REPORT_GAS=true npx hardhat test

npx hardhat run scripts/deploy.js --network basesepolia
npx hardhat run scripts/mint.js --network basesepolia
npx hardhat run scripts/burn.js --network basesepolia

npx hardhat verify --network sepolia 0xBB31B70163a798994eDB79c87861E96229182Dcb
```

## verify
```
npx hardhat verify --network base 0xa999542c71FEbba77602fBc2F784bA9BA0C850F6

npx hardhat verify --network basesepolia --constructor-args scripts/verify/meh-faucet-v1-args.js 0xEf4C3545edf08563bbC112D5CEf0A10B396Ea12E

```