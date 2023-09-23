// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// interaces
// iLendingPool
// iLoanContract
// iLoanFactory

// imports
// iButtonToken

contract loanRouter {
    function createAndBorrow() public {
        // transfer collateralTokens to this contract
        // button up the collateralTokens
        // call approve on buttonTokens
        // call create on loanFactory
        // call borrow on LendingPool
    }

    function convertAndCollect() public {
        // call convert on LoanContract
        // call collect on lendingPool
    }

    function repayAndCollect() public {
        // transfer stablecoins to this contract
        // approve stablecoins to be spent by loanContract
        // transfer ERC1155 debtTokens?
        // call repay on loanContract
        // call collect on lendingPool
        // unwrap collateral to borrower
    }
}
