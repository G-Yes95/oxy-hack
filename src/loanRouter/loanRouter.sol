// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// interfaces
// iLendingPool
// iLoanContract
// iLoanFactory

// imports
import "@buttonwood-protocol/button-wrappers/contracts/interfaces/IButtonToken.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract LoanRouter {
    mapping(address => address) public buttonMapping;

    constructor(address[] memory _rawCollateral, address[] memory _buttonToken) {
        buttonMapping[_rawCollateral[0]] = _buttonToken[0];
        buttonMapping[_rawCollateral[1]] = _buttonToken[1];
    }

    function createAndBorrow(address _rawCollateral, address _lendingPool, uint256 _amount) public {
        // transfer collateralTokens to this contract
        TransferHelper.safeTransfer(_rawCollateral, address(this), _amount);
        // approve collateral to be buttoned
        TransferHelper.safeApprove(_rawCollateral, buttonMapping[_rawCollateral], _amount);

        // call create on loanFactory
        // loanFactory.create(borrowerAddress, lendingPoolAddress, stablecoinAddress ); 

        // button up the collateralTokens into the new loan
        // TODO: Replace msg.sender with new loanContract address
        IButtonToken(buttonMapping[_rawCollateral]).mintFor(msg.sender, _amount);

        // call borrow on LendingPool
        // lendingPool.borrow()
    }

    function convertAndCollect( address _loanContract, address _lendingPool) public {
        // call convert on LoanContract
        // call collect on lendingPool
    }

    function repayAndCollect(address _loanContract, address _lendingPool) public {
        // transfer stablecoins to this contract
        // approve stablecoins to be spent by loanContract
        // call repay on loanContract
        // call collect on lendingPool
        // unwrap collateral to borrower
    }
}
