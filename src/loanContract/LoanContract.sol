// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../interfaces/ILoanContract.sol";
// The goal of LoanContract is to be a vault for collateral tokens

contract LoanContract is ILoanContract {
    // The stablecoin (e.g., USDC) to be borrowed from the pool.
    IERC20 public stableCoin;

    // The collateral asset to be supplied to this LoanContract.
    IERC20 public collateralToken;

    // The ERC1155 principal token and debt tokens that are tied to this loan
    IERC1155 public principalToken;
    IERC1155 public debtToken;

    // self-explanatory qty's
    uint256 public creationDate;
    uint256 public maturityDate;
    uint256 public initialTotalDebt;
    uint256 public initialPrincipal;
    uint256 public initialCollateralAmount;
    bool initialized;

    /// @inheritdoc ILoanContract
    function init(
        address _stableCoin, 
        address _collateralToken, // TODO change to buttonToken
        IERC1155 _principalToken,
        IERC1155 _debtToken
    ) external {
        require(!initialized, "Already initialized");
        stableCoin = IERC20(_stableCoin);
        collateralToken = IERC20(_collateralToken);
        principalToken = _principalToken;
        debtToken = _debtToken;

        initialCollateralAmount = collateralToken.balanceOf(address(this));
        debtToken.mint();
        initialized = true;
    }

    // function repay()
}
