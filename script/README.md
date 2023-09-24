# Using Scripts 

forge script script/MockERC20.s.sol --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY_PERSONAL --broadcast --verify --watch --etherscan-api-key 4DZZ49ARAJ8SXIC42GCWG3DF1WEEIJNQEI  -vvvv

forge script script/MockERC20.s.sol --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY_PERSONAL --broadcast --verify --watch --etherscan-api-key BVX4Q63QWIJ985HVDN5ZSWX5AP1P9FWBWZ  -vvvv

forge script script/Button.s.sol --rpc-url $BASE_RPC_URL --private-key $PRIVATE_KEY_PERSONAL --broadcast --verify --watch --etherscan-api-key BVX4Q63QWIJ985HVDN5ZSWX5AP1P9FWBWZ  -vvvv

forge create lib/button-wrappers/contracts/ButtonToken.sol:ButtonToken --rpc-url $BASE_RPC_URL

forge verify-contract 0xf5683b8f44a45430a45bcd81fb40c413710cd967 src/mocks/MockERC20.sol:MockERC20  BVX4Q63QWIJ985HVDN5ZSWX5AP1P9FWBWZ


cast send 0xf5683b8f44a45430a45bcd81fb40c413710cd967 "mint(address,uint256)" 0x7e16F5970f8092eE6d0eD7aA0E88FDB109Cd546D 1000000000000000000000  --rpc-url $BASE_RPC_URL  --private-key $PRIVATE_KEY_PERSONAL

cast send 0xf5683b8f44a45430a45bcd81fb40c413710cd967 "mint(address,uint256)" 0x7e16F5970f8092eE6d0eD7aA0E88FDB109Cd546D 1000000000000000000000  --rpc-url $BASE_RPC_URL  --private-key $PRIVATE_KEY_PERSONAL

cast call 0xf5683b8f44a45430a45bcd81fb40c413710cd967 "name()(string)"  --rpc-url $BASE_RPC_URL


cast send 0xE36A5a5CcAb4DaF557494Bb8c0838a5fF79dD677 "create(address,string,string,address)" 0x434995ff76c3f06267ad42cc5b646dbfef9351e0 "buttonHackBTC" "bhBTC"  0x061622c6bc0d88769a1176d50505699333d29fc5 --rpc-url $BASE_RPC_URL  --private-key $PRIVATE_KEY_PERSONAL 

cast send 0xE36A5a5CcAb4DaF557494Bb8c0838a5fF79dD677 "create(address,string,string,address)" 0x434995ff76c3f06267ad42cc5b646dbfef9351e0 "buttonHackETH" "bhETH" 0x5ef33d7f1c64f73116685505788d88a011fed056 --rpc-url $BASE_RPC_URL  --private-key $PRIVATE_KEY_PERSONAL 


forge create --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY_PERSONAL src/accountingTokens/DebtToken.sol:DebtToken
forge create --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY_PERSONAL src/accountingTokens/PrincipalToken.sol:PrincipalToken
forge create --rpc-url $GOERLI_RPC_URL --private-key $PRIVATE_KEY_PERSONAL src/loanContract/LoanContract.sol:LoanContract
forge create --rpc-url $GOERLI_RPC_URL --constructor-args 1000 1000 1000 1000  --private-key $PRIVATE_KEY_PERSONAL src/lendingPool/InterestRateStrategy.sol:InterestRateStrategy
forge create --rpc-url $GOERLI_RPC_URL --constructor-args 0xFaF34da075f23901dBe0F8Fc1F1242abefd2694E 0x4a6956DDc6609964312cB428a8830823AD4612D2 0x180065E86D77e57C3E789b868f9850F6958f29CC 0x9BcB22bfEC666023037D9C80b8d89f91466e787b  --private-key $PRIVATE_KEY_PERSONAL src/loanContract/LoanFactory.sol:LoanFactory
forge create --rpc-url $GOERLI_RPC_URL --constructor-args [0xF19162950528A40a27d922f52413d26f71B25926,0x989E061108095566D02eD059291D128524C74671] [0x37E4496AfD20e04Eec7A0Ac17410C0684a252287,0x69fF4E006cE79b436F66FA5e4761948975652276] --private-key $PRIVATE_KEY_PERSONAL src/loanRouter/LoanRouter.sol:LoanRouter
forge create --rpc-url $GOERLI_RPC_URL --constructor-args 0xaFF4481D10270F50f203E0763e2597776068CBc5 0x4a6956DDc6609964312cB428a8830823AD4612D2 0x3Bb44c06dBC200aAb4887250c173c1d2560d079F 0x9BcB22bfEC666023037D9C80b8d89f91466e787b --private-key $PRIVATE_KEY_PERSONAL src/lendingPool/LendingPool.sol:LendingPool
forge create --rpc-url $GOERLI_RPC_URL --constructor-args 0x022E292b44B5a146F2e8ee36Ff44D3dd863C915c 0x4a6956DDc6609964312cB428a8830823AD4612D2 0x3Bb44c06dBC200aAb4887250c173c1d2560d079F 0x9BcB22bfEC666023037D9C80b8d89f91466e787b --private-key $PRIVATE_KEY_PERSONAL src/lendingPool/LendingPool.sol:LendingPool


cast send 0x180065E86D77e57C3E789b868f9850F6958f29CC "setLoanFactory(address)" 0xBF85Db5E3C03f0b2f217Ad1EE2D483c6B2d66c4F --rpc-url $GOERLI_RPC_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast send 0x4a6956DDc6609964312cB428a8830823AD4612D2 "setLoanFactory(address)" 0xBF85Db5E3C03f0b2f217Ad1EE2D483c6B2d66c4F --rpc-url $GOERLI_RPC_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast send 0xF19162950528A40a27d922f52413d26f71B25926 "mint(address,uint256)" 0x0bFb0973ecccd5b3990DcDCa5114f0DC8BF57311 1000000000000000000000000  --rpc-url $GOERLI_RPC_URL --chain 5  --private-key $PRIVATE_KEY_PERSONAL


cast send 0x9A31fDAf3B0F9E507d8813c13F289d3E8d0FCC1A "setLoanRouter(address)" 0xDCEC347D3B12e53EB38f3576BD721c1D4eB8B2D9 --rpc-url $GOERLI_RPC_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL



forge create --rpc-url $LOCAL_HOST_URL --constructor-args 0x4DfC3bcFDb3B058f72Ea6F947E8805dc79963279 0x180065E86D77e57C3E789b868f9850F6958f29CC 0x4a6956DDc6609964312cB428a8830823AD4612D2 0x9BcB22bfEC666023037D9C80b8d89f91466e787b  --private-key $PRIVATE_KEY_PERSONAL src/loanContract/LoanFactory.sol:LoanFactory


forge create --rpc-url $LOCAL_HOST_URL --private-key $PRIVATE_KEY_PERSONAL src/accountingTokens/DebtToken.sol:DebtToken
forge create --rpc-url $LOCAL_HOST_URL --private-key $PRIVATE_KEY_PERSONAL src/accountingTokens/PrincipalToken.sol:PrincipalToken

forge create --rpc-url $LOCAL_HOST_URL --private-key $PRIVATE_KEY_PERSONAL src/loanContract/LoanContract.sol:LoanContract
forge create --rpc-url $LOCAL_HOST_URL --constructor-args 1000 1000 1000 1000  --private-key $PRIVATE_KEY_PERSONAL src/lendingPool/InterestRateStrategy.sol:InterestRateStrategy

forge create --rpc-url $LOCAL_HOST_URL --constructor-args 0xFaF34da075f23901dBe0F8Fc1F1242abefd2694E 0x180065E86D77e57C3E789b868f9850F6958f29CC 0x4a6956DDc6609964312cB428a8830823AD4612D2 0x9BcB22bfEC666023037D9C80b8d89f91466e787b  --private-key $PRIVATE_KEY_PERSONAL src/loanContract/LoanFactory.sol:LoanFactory

forge create --rpc-url $LOCAL_HOST_URL --constructor-args [0xF19162950528A40a27d922f52413d26f71B25926,0x989E061108095566D02eD059291D128524C74671] [0x37E4496AfD20e04Eec7A0Ac17410C0684a252287,0x69fF4E006cE79b436F66FA5e4761948975652276] --private-key $PRIVATE_KEY_PERSONAL src/loanRouter/LoanRouter.sol:LoanRouter

forge create --rpc-url $LOCAL_HOST_URL --constructor-args 0xaFF4481D10270F50f203E0763e2597776068CBc5 0x180065E86D77e57C3E789b868f9850F6958f29CC 0x3Bb44c06dBC200aAb4887250c173c1d2560d079F 0x9BcB22bfEC666023037D9C80b8d89f91466e787b --private-key $PRIVATE_KEY_PERSONAL src/lendingPool/LendingPool.sol:LendingPool


cast send 0xaFF4481D10270F50f203E0763e2597776068CBc5 "approve(address,uint)" 0x9A31fDAf3B0F9E507d8813c13F289d3E8d0FCC1A 1000000000000000000000000000000 --rpc-url $GOERLI_RPC_URL --chain 5  --private-key $PRIVATE_KEY_PERSONAL


cast send 0x9A31fDAf3B0F9E507d8813c13F289d3E8d0FCC1A "deposit(uint)" 10000000000000000000000 --rpc-url $GOERLI_RPC_URL --chain 5  --private-key $PRIVATE_KEY_PERSONAL

cast send 0x989E061108095566D02eD059291D128524C74671 "mint(address,uint)" 0x7e16F5970f8092eE6d0eD7aA0E88FDB109Cd546D 1000000000000000000000000 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast call 0x1a48B849552eC516b84556A5f8CBc26b54bF3FF9 "borrower()(address)" --rpc-url $GOERLI_RPC_URL



cast call 0x180065E86D77e57C3E789b868f9850F6958f29CC "balanceOf(address,uint)"

cast send 0x989E061108095566D02eD059291D128524C74671 "approve(address,uint)" 0x205971bF7a149cC6A6864A6e58807290622f10eD 1000000000000000000000000 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL


cast send 0x4B1DA90D2b1E2cda166993c04aB09D64e1AB0eA8 "createAndBorrow(address,address,address,uint,uint,uint)" 0x40D7C9A51cFb63f89aD85E1086eD7132b64d108B 0x989E061108095566D02eD059291D128524C74671  0xFF2BE0b640D20773e52faA405D940624f123933e 10000000000 604800 8 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast call 0xA6B4e7839034DC59084d98Ca5627A61f2A29F976 "buttonMapping(address)(address)" 0x989E061108095566D02eD059291D128524C74671 --rpc-url $LOCAL_HOST_URL


cast send 0x989E061108095566D02eD059291D128524C74671 "approve(address,uint)" 0x4B1DA90D2b1E2cda166993c04aB09D64e1AB0eA8 1000000000000000000000000 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL


cast send 0x4B1DA90D2b1E2cda166993c04aB09D64e1AB0eA8 "create(address,address,address,uint,uint,uint,uint)" 0x7e16F5970f8092eE6d0eD7aA0E88FDB109Cd546D 0xFF2BE0b640D20773e52faA405D940624f123933e 0x989E061108095566D02eD059291D128524C74671  100000000000 10000000 604800 8 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL


cast send 0x9A31fDAf3B0F9E507d8813c13F289d3E8d0FCC1A "setLoanRouter(address)" 0x14b11BDF7CF1214C5fcb0DC5D9139674c049d5D3 --rpc-url $GOERLI_RPC_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast send 0xE0C0FA47d87023f2914405A0FcB8096d7D85F9d5 "borrow(address,uint)" 0x7e16F5970f8092eE6d0eD7aA0E88FDB109Cd546D 100000 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast call 0xE0C0FA47d87023f2914405A0FcB8096d7D85F9d5 "loanRouter()(address)" --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast call 0x9A31fDAf3B0F9E507d8813c13F289d3E8d0FCC1A "loanRouter()(address)" --rpc-url $GOERLI_RPC_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL


cast send WETH mint 


cast send 0x69fF4E006cE79b436F66FA5e4761948975652276 "approve(address,uint)" 0x3Bb44c06dBC200aAb4887250c173c1d2560d079F 1000000000000000000000000 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL

cast call 0x989E061108095566D02eD059291D128524C74671 "name()(string)" 0 --rpc-url $LOCAL_HOST_URL --chain 5 --private-key $PRIVATE_KEY_PERSONAL



cast send 0x3Bb44c06dBC200aAb4887250c173c1d2560d079F "createAndBorrow(address,address,address,uint,uint,uint)" 0x40D7C9A51cFb63f89aD85E1086eD7132b64d108B 0x69fF4E006cE79b436F66FA5e4761948975652276 



