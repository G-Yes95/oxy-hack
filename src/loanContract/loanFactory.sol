// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//imports
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./LoanContract.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

// interfaces

// IAccounting Token
interface IAccountingToken is IERC1155 {
    function mint(address account, uint256 id, uint256 value) external;
    function burn(address account, uint256 id, uint256 value) external;
}

// iInterestRateStrategy
interface IInterestRateStrategy {
    function calculateInterestRates(
        address _asset,
        address _poolToken,
        uint256 _liquidityAdded,
        uint256 _liquidityTaken,
        uint256 _totalDebt
    ) external view returns (uint256, uint256);
}

// iLendingPool
interface ILendingPool {
    function stableCoin() external view returns (IERC20);
    function totalDebt() external view returns (uint256);
}

contract LoanFactory {
    address public immutable template;
    IInterestRateStrategy public immutable interestRateStrategy;
    IAccountingToken public principalToken;
    IAccountingToken public debtToken;

    constructor(address _loanContract, address _principalToken, address _debtToken, address _interestRateStrategy) {
        template = _loanContract;
        principalToken = IAccountingToken(_principalToken);
        debtToken = IAccountingToken(_debtToken);
        interestRateStrategy = IInterestRateStrategy(_interestRateStrategy);
    }

    //modifier for only loanRouter
    function create(address _borrower, address _lendingPool, uint256 _amount, uint256 _collateralQty, uint256 _paymentFrequency, uint256 _numPayments)
        public
        returns (address)
    {
        // clone loanContract
        address clone = Clones.clone(template);

        // calculate principal and debt token qty with interest rate strategy
        address _asset = address(ILendingPool(_lendingPool).stableCoin());
        uint256 _totalDebt = ILendingPool(_lendingPool).totalDebt();
        (, uint256 _rate) = interestRateStrategy.calculateInterestRates(_asset, _lendingPool, 0, _amount, _totalDebt);
        uint256 dQty = _amount * _rate / 1e4;

        // mint principalTokens to lendingPool
        principalToken.mint(_lendingPool, uint256(uint160(clone)), _amount);
        // mint debtTokens to borrower
        debtToken.mint(_borrower, uint256(uint160(clone)), dQty);

        // LoanContract.init(_stableCoin, _collateralToken, _principalToken, _debtToken);
        return clone;
    }
}
