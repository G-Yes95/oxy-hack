// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// interfaces

// iLendingPool
interface ILendingPool {
    function stableCoin() external view returns (IERC20);
    function totalDebt() external view returns (uint256);
    function borrow(address _borrower, uint256 _amount) external;
    function collectPayment(address _loanContract, uint256 _tokenId, uint256 _amount) external;
}
// iLoanContract
// iLoanFactory

interface ILoanFactory {
    function create(address _borrower, address _lendingPool, uint256 _amount, uint256 _collateralQty)
        external
        returns (address);
}

// imports
import "@buttonwood-protocol/button-wrappers/contracts/interfaces/IButtonToken.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";

contract LoanRouter {
    mapping(address => address) public buttonMapping;

    constructor(address[] memory _rawCollateral, address[] memory _buttonToken) {
        buttonMapping[_rawCollateral[0]] = _buttonToken[0];
        buttonMapping[_rawCollateral[1]] = _buttonToken[1];
    }

    function createAndBorrow(address _loanFactory, address _rawCollateral, address _lendingPool, uint256 _amount)
        public
    {
        // transfer collateralTokens to this contract
        TransferHelper.safeTransfer(_rawCollateral, address(this), _amount);
        // approve collateral to be buttoned
        TransferHelper.safeApprove(_rawCollateral, buttonMapping[_rawCollateral], _amount);

        // calculate relevant qty's
        address _asset = address(ILendingPool(_lendingPool).stableCoin());
        uint256 _liquidityTaken =
            _amount * IERC20Metadata(_asset).decimals() / IERC20Metadata(_rawCollateral).decimals() / 2;
        uint256 collateralQty = IButtonToken(buttonMapping[_rawCollateral]).underlyingToWrapper(_amount);
        // clone and init loanContract
        address clone = ILoanFactory(_loanFactory).create(msg.sender, _lendingPool, _liquidityTaken, collateralQty);

        // button up the collateralTokens into the new loan
        IButtonToken(buttonMapping[_rawCollateral]).mintFor(clone, _amount);

        // call borrow on LendingPool
        ILendingPool(_lendingPool).borrow(msg.sender, _liquidityTaken);
    }

    function convertAndCollect(address _loanContract, address _lendingPool) public {
        // call convert on LoanContract
        // call collect on lendingPool
        uint256 _amount = ILendingPool(_lendingPool).stableCoin().balanceOf(_loanContract);
        ILendingPool(_lendingPool).collectPayment(_loanContract, uint256(uint160(_loanContract)), _amount);
    }

    function repayAndCollect(address _loanContract, address _lendingPool, uint256 _amount) public {
        // transfer stablecoins to this contract
        address _stablecoin = address(ILendingPool(_lendingPool).stableCoin());
        TransferHelper.safeTransfer(_stablecoin, address(this), _amount);

        // approve stablecoins to be spent by loanContract
        TransferHelper.safeApprove(_stablecoin, _loanContract, _amount);

        // call repay on loanContract

        // call collect on lendingPool
        ILendingPool(_lendingPool).collectPayment(_loanContract, uint256(uint160(_loanContract)), _amount);
        // unwrap collateral to borrower
    }
}
