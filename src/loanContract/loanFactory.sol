// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//imports
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./LoanContract.sol";

// interfaces

// IAccounting Token 
interface IAccountingToken is IERC1155 {
  function mint(address account, uint256 id, uint256 value) external; 
  function burn(address account, uint256 id, uint256 value) external; 
}

// iInterestRateStrategy
interface IInterestRateStrategy { 
  
}
// iLendingPool

contract LoanFactory {

    address public immutable template;
    IAccountingToken public principalToken; 
    IAccountingToken public debtToken; 

    constructor(address _loanContract, address _principalToken, address _debtToken) {
        template = _loanContract;
        principalToken = IAccountingToken(_principalToken); 
        debtToken = IAccountingToken(_debtToken); 
    }

    //modifier for only loanRouter
    function create(address _borrower, address _lendingPool, uint256 _amount) public {
        
        // clone loanContract
        address clone = Clones.clone(template);

        // calculate principal and debt token qty with interest rate strategy
        uint256 pQty = _amount; 
        uint256 dQty = _amount; 

        // mint principalTokens to lendingPool
        principalToken.mint(_lendingPool, uint256(uint160(clone)), pQty);
        // mint debtTokens to borrower
        debtToken.mint(_borrower, uint256(uint160(clone)), dQty);

        // call init on loanContract (passing in qty's)
        // LoanContract.init(_stableCoin, _collateralToken, _principalToken, _debtToken);



    }
}
