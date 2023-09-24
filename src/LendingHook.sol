// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseHook} from "../lib/v4-periphery/contracts/BaseHook.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Hooks} from "../lib/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "../lib/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "../lib/v4-core/contracts/types/PoolId.sol";
import {PoolKey} from "../lib/v4-core/contracts/types/PoolKey.sol";
import {BalanceDelta} from "../lib/v4-core/contracts/types/BalanceDelta.sol";
import {TickMath} from "../lib/v4-core/contracts/libraries/TickMath.sol";
import {LendingPool} from "../src/lendingPool/LendingPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./UniswapPool.sol";

// import "forge-std/Console.sol";

contract LendingHook is BaseHook {
    using PoolIdLibrary for PoolId;

    // Address of the lending pool
    LendingPool public lendingPool;

    IUniswapPool public uniswapPool;

    // Keeps track of where the liquidity currently is
    bool public liquidityInUniswap;

    // Users
    address public user1;
    address public user2;

    struct LiquidityRange {
        int24 tickLower; // The lower tick of the range
        int24 tickUpper; // The upper tick of the range
    }

    // TODO remove this and setter in prod
    uint160 sqrtPriceX96;

    // The key is the pool ID (PoolId), which is derived from the PoolKey using the toPoolId() function.
    // The value is the LiquidityRange struct that represents the range of ticks where liquidity has been provided.
    mapping(PoolId => mapping(address => LiquidityRange))
        public liquidityRanges;

    // Initialize BaseHook and ERC1155 parent contracts in the constructor
    constructor(
        IPoolManager _poolManager,
        address _lendingPool,
        address _uniswapPool
    ) BaseHook(_poolManager) {
        lendingPool = LendingPool(_lendingPool);
        liquidityInUniswap = true;
        uniswapPool = IUniswapPool(_uniswapPool);
    }

    // function validateHookAddress(BaseHook _this) internal pure override {}

    // Required override function for BaseHook to let the PoolManager know which hooks are implemented
    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
                beforeInitialize: false,
                afterInitialize: false,
                beforeModifyPosition: false,
                afterModifyPosition: false,
                beforeSwap: true,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false
            });
    }

    // Hooks
    function beforeSwap(
        address,
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    ) external override returns (bytes4) {
        UniswapPool.LiquidityRange memory range = uniswapPool.liquidityRanges(
            user1
        ); // Because fuck it...

        // // Step 1: Get the full tuple
        // (uint160 sqrtPriceX96FromTuple, , , ) = poolManager.getSlot0(
        //     PoolIdLibrary.toId(poolKey)
        // );

        // Step 2: Use the extracted values
        // TODO will use in production. We use setters to test functionality
        uint160 adjustedSqrtPriceX96 = estimatePriceAfterSwap(
            sqrtPriceX96,
            params.amountSpecified,
            params.zeroForOne
        );

        // Convert tickLower and tickUpper to their respective sqrtPriceX96 values
        uint160 lowerSqrtPriceX96 = TickMath.getSqrtRatioAtTick(
            range.tickLower
        );

        uint160 upperSqrtPriceX96 = TickMath.getSqrtRatioAtTick(
            range.tickUpper
        );

        if (liquidityInUniswap) {
            if (
                sqrtPriceX96 < lowerSqrtPriceX96 ||
                sqrtPriceX96 > upperSqrtPriceX96
            ) {
                // If the liquidity is in Uniswap and the estimated price after the swap is outside the range
                // Here we assume that liquidityToRetrieve is the stable coin and is the only thing we want to deposit in lending pool
                (uint256 liquidityToRetrieve, ) = _retrieveLiquidity(
                    PoolIdLibrary.toId(poolKey)
                );
                IERC20(lendingPool.stableCoin()).approve(
                    address(lendingPool),
                    liquidityToRetrieve
                );
                lendingPool.deposit(liquidityToRetrieve, user1);
                liquidityInUniswap = false;
            }
            // If the liquidity is in Uniswap and the estimated price after the swap is within the range, do nothing.
        } else {
            if (
                sqrtPriceX96 >= lowerSqrtPriceX96 &&
                sqrtPriceX96 <= upperSqrtPriceX96
            ) {
                // If the liquidity is in the lending pool and the estimated price after the swap is within the range
                uint256 liquidityToProvide = lendingPool.withdraw(
                    uint256(params.amountSpecified)
                ); // Assuming the lendingPool has a withdraw function that returns the liquidity
                _provideLiquidityToUniswap(PoolIdLibrary.toId(poolKey), user1);
                liquidityInUniswap = true;
            }
            // If the liquidity is in the lending pool and the estimated price after the swap is outside the range, do nothing.
        }
        return BaseHook.beforeSwap.selector;
    }

    // Helper functions
    function _retrieveLiquidity(
        PoolId poolId
    ) internal returns (uint256, uint256) {
        // Get the ammount of liquidity in the uniswap pool
        uint256 userLiquidity = poolManager.getLiquidity(
            poolId,
            user1,
            liquidityRanges[poolId][user1].tickLower,
            liquidityRanges[poolId][user1].tickUpper
        );
        // Withdraw from Uniswap into this contract
        (uint256 amountTokenA, uint256 amountTokenB) = uniswapPool
            .withdrawLiquidity(user1, userLiquidity);

        // Return token amounts
        return (amountTokenA, amountTokenB);
    }

    function _provideLiquidityToUniswap(PoolId poolId, address user) internal {
        // get amount of liquidity in the lending pool
        uint256 userPoolTokenBalance = lendingPool.balanceOf(user); // This should be equal to the amount of money he deposited in the lending pool
        // withdraw liquidity from lending pool into this contract
        lendingPool.withdraw(userPoolTokenBalance);
        // call uniswap deposit liquidity
        uniswapPool.depositLiquidity(userPoolTokenBalance, 0);
    }

    function convertSqrtPriceX96ToPrice(
        uint160 sqrtPriceX96
    ) public pure returns (uint256) {
        // Convert the sqrtPriceX96 to a regular price using Uniswap's formula.
        uint256 price = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) >> 96;
        return price;
    }

    function estimatePriceAfterSwap(
        uint160 currentSqrtPriceX96,
        int256 amountSpecified,
        bool zeroForOne
    ) internal pure returns (uint160) {
        // Placeholder logic: This is a very naive estimation and is likely not accurate.
        uint256 priceImpact = uint256(amountSpecified) / 10000; // Assuming 0.01% price impact per unit amount
        uint160 adjustedSqrtPriceX96;

        if (zeroForOne) {
            adjustedSqrtPriceX96 = currentSqrtPriceX96 - uint160(priceImpact);
        } else {
            adjustedSqrtPriceX96 = currentSqrtPriceX96 + uint160(priceImpact);
        }

        return adjustedSqrtPriceX96;
    }

    // SETTERS for hackathon use only
    function setUserAddress(address _user1, address _user2) public {
        user1 = _user1;
        user2 = _user2;
    }

    function setPrice(uint160 _sqrtPriceX96) public {
        sqrtPriceX96 = _sqrtPriceX96;
    }
}

// INTERFACES
interface IUniswapPool {
    function liquidityRanges(
        address
    ) external returns (UniswapPool.LiquidityRange memory);

    function withdrawLiquidity(
        address user,
        uint256 liquidityTokens
    ) external returns (uint256, uint256);

    function depositLiquidity(
        uint256 amountTokenA,
        uint256 amountTokenB
    ) external;
}
