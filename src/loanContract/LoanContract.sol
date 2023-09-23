// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "../interfaces/ILoanContract.sol";
import "../accountingTokens/DebtToken.sol";
import "../accountingTokens/PrincipalToken.sol";

// The goal of LoanContract is to be a vault for collateral tokens
contract LoanContract is ILoanContract {
    // The tokenID that will be used in DebtToken and PrincipalToken
    // @dev this will be set as uint256(uint160(address(this)) in the init()
    uint256 tokenId;

    // Address of the lendingPool
    address lendingPool;

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
        address _lendingPool,
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
        lendingPool = _lendingPool;
        creationDate = block.timestamp;
        numOfPayments = _numOfPayments;
        stableCoin = IERC20(_stableCoin);
        collateralToken = IERC20(_collateralToken);
        initialDebtAmount = _initialDebtAmount;
        initialPrincipalAmount = _initialPrincipalAmount;
        periodicPaymentAmount = (_initialDebtAmount - _initialPrincipalAmount) / _numOfPayments;
        initialCollateralAmount = _initialCollateralAmount;
        tokenId = uint256(uint160(address(this)));

        initialized = true;
    }
    /// @inheritdoc ILoanContract
    function repay(address _holder, uint256 _debtAmount, uint256 _collateralAmount) external {
        debtToken.burn(_holder, tokenId, _debtAmount);
        collateralToken.transferFrom(msg.sender, address(this), _collateralAmount);
    }

    /// @inheritdoc ILoanContract
    function convert() external {
        uint256 maxConvertibleAmount = calculateMaxConvertibleAmount();
        // TODO swap
    }

    /// @inheritdoc ILoanContract
    function redeem(uint256 _amount) external {
        uint maxRedeemableAmount = calculateMaxRedeemableAmount();
        require(_amount <= maxRedeemableAmount, "redeem too much");
        principalToken.burn(lendingPool, tokenId, _amount);

        stableCoin.transfer(lendingPool, ((debtToken.totalSupply(tokenId) / principalToken.totalSupply(tokenId)) * _amount));
    }


    /// @inheritdoc ILoanContract
     function calculateMaxConvertibleAmount() public view returns (uint256) {    
      uint256 currentWeekNumber = (block.timestamp - creationDate) / 604800; // 1 week
      uint256 currentDebtAmount = debtToken.totalSupply(tokenId);
      uint256 totalInterest = initialDebtAmount - currentDebtAmount;
      uint256 exectedInterest = currentWeekNumber * periodicPaymentAmount;

      return exectedInterest > totalInterest ? exectedInterest - totalInterest : 0;
    } 

    /// @inheritdoc ILoanContract
     function calculateMaxRedeemableAmount() public view returns (uint256) {
      return stableCoin.balanceOf(address(this)) / (debtToken.totalSupply(tokenId) / principalToken.totalSupply(tokenId));
    }
}
