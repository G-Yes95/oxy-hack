// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ILoanContract {
    /**
     * @notice Initializes the loan contract by
     * 1. setting variables
     * 2. setting the initialCollateralAmount to be the balanceOf collateral
     * @dev should only be called once
     * @param _stableCoin the token address to borrow
     * @param _collateralToken the token address to collateralize
     * @param _initialDebtAmount the intial debt token amount
     * @param _initialPrincipalAmount the intial principal token amount
     * @param _initialCollateralAmount the collateral token amount
     * @param _paymentFrequency either weekly or monthly (in seconds)
     * @param _numOfPayments the number of payments
     */
    function init(address _lendingPool, address _stableCoin, address _collateralToken, uint256 _initialDebtAmount, uint256 _initialPrincipalAmount, uint256 _initialCollateralAmount, uint256 _paymentFrequency, uint256 _numOfPayments)
        external;

    /**
     * @notice repays the loan with collateral token
     * 1. Pulls the collateral from Router
     * 2. Burn the debt tokens from holder
     * @dev expects to be called from LoanRouter
     * @param _holder account to burn the debt token from
     * @param _debtAmount amount of debt to repay
     * @param _collateralAmount amount of collateral to pull
     */
    function repay(address _holder, uint256 _debtAmount, uint256 _collateralAmount) external;

    /**
     * @notice Swaps the Max convertable amount of collateral to stable using SwapRouter
     * @dev expects to be called from LoanRouter
     */
    function convert() external;

    /**
     * @notice Sends stable to LendingPool and returns the collateral
     * @dev expects to be called from LendingPool
     * @param _amount amount of collateral to redeem
     */
    function redeem(uint256 _amount) external;


    /**
     * @return the max PrincipalTokens that can be redeemed at current moment
     */
    function calculateMaxRedeemableAmount() external view returns (uint256);

    /**
     * @return the max allowable amount to convert
     */
    function calculateMaxConvertibleAmount() external view returns(uint256);
}
