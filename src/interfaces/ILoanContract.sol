// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";

interface ILoanContract {
    /**
     * @notice Initializes the loan contract by
     * 1. setting variables
     * 2. setting the initialCollateralAmount to be the balanceOf collateral
     * @dev should only be called once
     */
    function init(
        IERC20 _stableCoin,
        IERC20 _collateralToken,
        IERC1155 _principalToken,
        IERC1155 _debtToken
    ) external;

    /**
     * @notice repays the loan with collateral token
     *
     */
    // function repay(uint256 _amount) external;

    // function redeem(uint256 _amount) external;

    // function convert(uint256 _amount) external;

    // function maxAmountRedeemable() external view;

    // function maxAmountConvertible() external view;
}
