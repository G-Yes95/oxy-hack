// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LendingPool is ERC20("PoolToken", "PT"), ERC1155Holder {
    using SafeERC20 for IERC20;

    // DATA VARIABLES

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

    // EVENT DEFINITIONS

    event Deposited(address indexed user, uint256 amount);
    event Borrowed(address indexed borrower, uint256 amount);
    event PoolTokensMinted(address indexed lender, uint256 poolTokens);
    event Withdrawal(address indexed lender, uint256 amount);
    event TokenBurned(address indexed lender, uint256 tokenAmount);

    // FUNCTION MODIFIERS

    modifier onlyLoanRouter() {
        require(msg.sender == loanRouter, "Caller is not authorized");
        _;
    }

    // CONSTRUCTOR

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

    // UTILITY FUNCTIONS

    /**
     * @dev This function allows the owner to set the address of the loanRouter.
     */
    function setLoanRouter(address _loanRouter) external {
        loanRouter = _loanRouter;
    }

    /**
     * @dev This function allows the owner to set the address of the principalToken.
     */
    function setPrincipalToken(address _principalToken) external {
        principalToken = IERC1155(_principalToken);
    }

    /**
     * @dev This function allows the owner to set the address of the interest rate strategy contract.
     */
    function setInterestRateStrategy(address _interestRateStrategy) external {
        interestRateStrategy = IInterestRateStrategy(_interestRateStrategy);
    }

    // CONTRACT FUNCTIONS

    /**
     * @dev Called by lender to deposit funds into the pool.
     */

    function deposit(uint256 _amount, address _for) external {
        require(_amount > 0, "Amount must be greater than 0");

        // Re-calculate the interest rates
        interestRateStrategy.calculateInterestRates(
            address(stableCoin),
            address(this),
            _amount,
            0,
            totalDebt
        );

        // transfer stablecoins
        stableCoin.safeTransferFrom(msg.sender, address(this), _amount);
        emit Deposited(msg.sender, _amount);

        _mint(_for, _amount);
        emit PoolTokensMinted(msg.sender, _amount);
    }

    /**
     * @dev Called by lender to withdraw funds into the pool.
     */

    function withdraw(uint256 _amount) external returns (uint256) {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            _amount <= stableCoin.balanceOf(address(this)),
            "Amount exceeds pool balance"
        );

        // Re-calculate the interest rates
        interestRateStrategy.calculateInterestRates(
            address(stableCoin),
            address(this),
            0,
            _amount,
            totalDebt
        );

        // Calculate maximum amount of stable coins the lender can withdraw - make thismits own view function
        uint256 maxWithdrawal = (balanceOf(msg.sender) *
            stableCoin.balanceOf(address(this))) / totalSupply();
        require(_amount <= maxWithdrawal, "Withdrawal exceeds allowed amount");

        // Calculating how many pool tokens need to be burned
        uint256 requiredPoolTokens = (_amount * totalSupply()) /
            stableCoin.balanceOf(address(this));

        // Burns the pool tokens directly at the lender's address
        _burn(msg.sender, requiredPoolTokens);
        emit TokenBurned(msg.sender, requiredPoolTokens);

        // transfers stablecoins to caller in proportion to the tokens he sent
        stableCoin.safeTransfer(msg.sender, _amount);
        emit Withdrawal(msg.sender, _amount);

        // return the amount of stablecoins withdrawn so that LendingHook can use it.
        return _amount;
    }

    /**
     * @dev This function collects the repayments that the borrower has made to the loan contract.
     * The function is called by the loan router when the borrower repays loans or interest.
     * This function calls the collectPayment function in the loan contract.
     * @param _loanContract The address of the loan contract.
     * @param _tokenId The ID of the principal token.
     */
    function collectPayment(
        address _loanContract,
        uint256 _tokenId,
        uint256 _amount
    ) external onlyLoanRouter {
        // Get the balance of principal tokens held by this contract
        uint256 principalTokenBalance = principalToken.balanceOf(
            address(this),
            _tokenId
        );

        // Dynamically cast the address of the ILoanContract interface
        ILoanContract loanContract = ILoanContract(_loanContract);

        // Update the total debt value
        totalDebt -= _amount;

        // Re-calculate the interest rates
        interestRateStrategy.calculateInterestRates(
            address(stableCoin),
            address(this),
            _amount,
            0,
            totalDebt
        );

        // Call the collectPayment function in the loan contract - does principal token need approval to be burned?
        loanContract.redeem(Math.min(principalTokenBalance, _amount));
    }

    /**
     * @dev Called by the loanRouter. This function accepts the principal token and sends the borrowed funds to the loanRouter.
     */
    function borrow(
        address _borrower,
        uint256 _amount
    ) external onlyLoanRouter {
        require(
            _amount <= stableCoin.balanceOf(address(this)),
            "Not enough funds in the pool"
        );

        // Update the total debt value
        totalDebt += _amount;

        // Re-calculate the interest rates
        interestRateStrategy.calculateInterestRates(
            address(stableCoin),
            address(this),
            0,
            _amount,
            totalDebt
        );

        // Transfer the requested stableCoin to the loanRouter.
        stableCoin.safeTransfer(_borrower, _amount);
        emit Borrowed(_borrower, _amount);
    }
}

// INTERFACES

interface ILoanContract {
    function redeem(uint256 debtTokenBalance) external;
}

interface IInterestRateStrategy {
    function calculateInterestRates(
        address _asset,
        address _poolToken,
        uint256 _liquidityAdded,
        uint256 _liquidityTaken,
        uint256 _totalDebt
    ) external view returns (uint256, uint256);
}
