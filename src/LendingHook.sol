// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseHook} from "../lib/v4-periphery/contracts/BaseHook.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Hooks} from "../lib/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "../lib/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "../lib/v4-core/contracts/types/PoolId.sol";
import {PoolKey} from "../lib/v4-core/contracts/types/PoolKey.sol";
import {BalanceDelta} from "../lib/v4-core/contracts/types/BalanceDelta.sol";

contract LendingHook is BaseHook {
    using PoolIdLibrary for PoolId;

    // Address of the lending pool
    address public lendingPool;

    struct LiquidityRange {
        int24 tickLower; // The lower tick of the range
        int24 tickUpper; // The upper tick of the range
    }

    // The key is the pool ID (PoolId), which is derived from the PoolKey using the toPoolId() function.
    // The value is the LiquidityRange struct that represents the range of ticks where liquidity has been provided.
    mapping(PoolId => LiquidityRange) public liquidityRanges;

    // Initialize BaseHook and ERC1155 parent contracts in the constructor
    constructor(
        IPoolManager _poolManager,
        address _lendingPool
    ) BaseHook(_poolManager) {
        lendingPool = _lendingPool;
    }

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
        LiquidityRange memory range = liquidityRanges[
            PoolIdLibrary.toId(poolKey)
        ];

        // Step 1: Get the full tuple
        (uint160 sqrtPriceX96FromTuple, , , ) = poolManager.getSlot0(
            PoolIdLibrary.toId(poolKey)
        );

        // Step 2: Use the extracted value
        uint160 sqrtPriceX96 = sqrtPriceX96FromTuple;

        uint256 estimatedPriceAfterSwap = estimatePriceAfterSwap(
            sqrtPriceX96,
            params.amountSpecified,
            params.zeroForOne
        );

        if (
            estimatedPriceAfterSwap < range.tickLower ||
            estimatedPriceAfterSwap > range.tickUpper
        ) {
            // If the estimated price after the swap is outside the range, get all the liquidity provided
            uint256 liquidityToRetrieve = _retrieveLiquidity(
                PoolIdLibrary.toId(poolKey)
            );

            // Deposit the retrieved liquidity in the lending pool
            lendingPool.deposit(liquidityToRetrieve);
        }
        return BaseHook.beforeSwap.selector;
    }

    function afterSwap(
        address,
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override returns (bytes4) {
        LiquidityRange memory range = liquidityRanges[
            PoolIdLibrary.toId(poolKey)
        ];

        uint256 currentPrice = convertSqrtPriceX96ToPrice(poolKey.sqrtPriceX96);

        if (currentPrice < range.tickLower || currentPrice > range.tickUpper) {
            // If it is outside the range, get all the liquidity provided
            uint256 liquidityToRetrieve = _retrieveLiquidity(
                PoolIdLibrary.toId(poolKey)
            );

            // Deposit the retrieved liquidity in the lending pool
            lendingPool.deposit(liquidityToRetrieve);
        }

        return BaseHook.afterSwap.selector;
    }

    // Helper functions
    function _retrieveLiquidity(PoolId poolId) internal returns (uint256) {
        // Retrieve the liquidity for the given pool. This will burn the liquidity tokens and remove the liquidity from the pool.
        uint256 liquidity = poolManager.burn(
            poolId,
            address(this),
            address(this)
        );

        // Update the liquidityRanges mapping to reflect the removed liquidity
        delete liquidityRanges[poolId];

        return liquidity;
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
    ) internal pure returns (uint256) {
        // Placeholder logic: This is a very naive estimation and is likely not accurate.
        uint256 priceImpact = uint256(amountSpecified) / 10000; // Assuming 0.01% price impact per unit amount
        if (zeroForOne) {
            return uint256(currentSqrtPriceX96) - priceImpact;
        } else {
            return uint256(currentSqrtPriceX96) + priceImpact;
        }
    }
}
