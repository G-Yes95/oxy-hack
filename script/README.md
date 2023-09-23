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
