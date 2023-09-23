// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LendingPool is
    ERC20("PoolToken", "PT"),
    ReentrancyGuard,
    OwnableUpgradeable
{
    using SafeERC20 for IERC20;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    // This represents the stablecoin (e.g., USDC) being supplied to and borrowed from the pool.
    IERC20 public stableCoin;

    // This represents the ERC115 principal token that the loanRouter will swap the stablecoins with
    IERC1155 public principalToken;

    // The loanRouter is the contract that interfaces between the pool and the loan contract.
    address public loanRouter;

    // The interest rate strategy contract
    IInterestRateStrategy public interestRateStrategy;

    // Variable to keep track of the total debt owed to the pool
    uint256 public totalDebt;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed borrower, uint256 amount);
    event PoolTokensMinted(address indexed lender, uint256 poolTokens);
    event Withdrawal(address indexed lender, uint256 amount);
    event TokenBurned(address indexed lender, uint256 tokenAmount);

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    modifier onlyLoanRouter() {
        require(msg.sender == loanRouter, "Caller is not authorized");
        _;
    }

    /********************************************************************************************/
    /*                                       CONSTRUCTOR                                        */
    /********************************************************************************************/

    constructor(
        address _stableCoin,
        address _principalToken,
        address _loanRouter,
        address _interestRateStrategy
    ) {
        stableCoin = IERC20(_stableCoin);
        loanRouter = _loanRouter;
        principalToken = IERC1155(_principalToken);
        interestRateStrategy = IInterestRateStrategy(_interestRateStrategy);
        totalDebt = 0;
    }
}
