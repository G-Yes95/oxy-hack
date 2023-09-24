// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/accountingTokens/DebtToken.sol"; 
import "../src/accountingTokens/PrincipalToken.sol"; 
import "../src/lendingPool/LendingPool.sol"; 
import "../src/lendingPool/InterestRateStrategy.sol"; 
import "../src/mocks/MockERC20.sol"; 
import {LoanRouter} from "../src/loanRouter/loanRouter.sol"; 
import {LoanFactory} from "../src/loanContract/loanFactory.sol";
import {LoanContract} from "../src/loanContract/LoanContract.sol"; 


contract CreateBorrow is Test {

    DebtToken dToken = DebtToken(0x180065E86D77e57C3E789b868f9850F6958f29CC); 
    PrincipalToken pToken = PrincipalToken(0x4a6956DDc6609964312cB428a8830823AD4612D2); 
    InterestRateStrategy irStratefy = InterestRateStrategy(0x9BcB22bfEC666023037D9C80b8d89f91466e787b); 
    LendingPool lendPool = LendingPool(0x9A31fDAf3B0F9E507d8813c13F289d3E8d0FCC1A); 
    LoanFactory loanFactory = LoanFactory(0xBF85Db5E3C03f0b2f217Ad1EE2D483c6B2d66c4F); 
    LoanRouter loanRouter = LoanRouter(0xDCEC347D3B12e53EB38f3576BD721c1D4eB8B2D9); 
    MockERC20 wbtc = MockERC20(0xF19162950528A40a27d922f52413d26f71B25926); 

    function setUp() public {
    }

    function testIncrement() public {

        vm.startPrank(0x0bFb0973ecccd5b3990DcDCa5114f0DC8BF57311);

        wbtc.approve(address(loanRouter), 100e18);

        address loan = loanRouter.createAndBorrow(address(loanFactory), address(wbtc), address(lendPool), 100e18, 604800, 8);

        lendPool.stableCoin().approve(address(loanRouter), 1e15); 
        loanRouter.repayAndCollect(loan, address(lendPool), 1e15);

        vm.stopPrank();

    } 

}
