// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "../interfaces/ILoanContract.sol";
import "../accountingTokens/DebtToken.sol";
import "../accountingTokens/PrincipalToken.sol";

// The goal of LoanContract is to be a vault for collateral tokens
contract LoanContract is ILoanContract {
    // Address of the loanRouter
    address loanRouter;

    // The stablecoin (e.g., USDC) to be borrowed from the pool.
    IERC20 public stableCoin;

    // The collateral asset to be supplied to this LoanContract.
    IERC20 public collateralToken;

    // The ERC1155 principal token and debt tokens that are tied to this loan
    PrincipalToken public principalToken; // TODO make const
    DebtToken public debtToken;

    uint256 internalCollateralBalance;

    // self-explanatory qty's
    uint256 public creationDate;
    uint256 public maturityDate;
    uint256 public numOfPayments;
    uint256 public initialDebtAmount;
    uint256 public initialPrincipalAmount;
    uint256 public periodicPaymentAmount;
    uint256 public initialCollateralAmount;
    bool initialized;

    function init(
        // address _loanRouter,
        address _stableCoin, 
        address _collateralToken, // TODO change to buttonToken
        uint256 _initialDebtAmount,
        uint256 _initialPrincipalAmount,
        uint256 _initialCollateralAmount,
        uint256 _numOfPayments
    ) external {
        require(!initialized, "Already initialized");
        require(_numOfPayments > 0, "invalid num of payments");
        // loanRouter = _loanRouter;
        creationDate = block.timestamp;
        numOfPayments = _numOfPayments;
        stableCoin = IERC20(_stableCoin);
        collateralToken = IERC20(_collateralToken);
        initialDebtAmount = _initialDebtAmount;
        initialPrincipalAmount = _initialPrincipalAmount;
        periodicPaymentAmount = (_initialDebtAmount - _initialPrincipalAmount) / _numOfPayments;
        initialCollateralAmount = _initialCollateralAmount;

        initialized = true;
    }
    /// @inheritdoc ILoanContract
    function repay(address _holder, uint256 _debtAmount, uint256 _collateralAmount) external {
        debtToken.burn(_holder, uint256(uint160(address(this))), _debtAmount);
        collateralToken.transferFrom(msg.sender, address(this), _collateralAmount);
    }

    /// @inheritdoc ILoanContract
    function convert() external {
        uint256 maxConvertibleAmount = calculateMaxConvertibleAmount();
        // TODO swap
    }

    /// @inheritdoc ILoanContract
     function calculateMaxConvertibleAmount() public view returns (uint256) {    
      uint256 currentWeekNumber = (block.timestamp - creationDate) / 604800; // 1 week
      uint256 currentDebtAmount = debtToken.totalSupply(uint256(uint160(address(this))));
      uint256 totalInterest = initialDebtAmount - currentDebtAmount;
      uint256 exectedInterest = currentWeekNumber * periodicPaymentAmount;

      return exectedInterest > totalInterest ? exectedInterest - totalInterest : 0;
    } 

    /// @inheritdoc ILoanContract
     function calculateMaxRedeemableAmount() public view {

      // get balance of stablecoins
      // divide balance by (totalSupplyDebtTokens)/(totalSupplyPrincipalTokens)
  
    }
}
