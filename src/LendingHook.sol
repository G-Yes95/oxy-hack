// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

contract LendingHook is BaseHook, ERC1155 {
    using PoolIdLibrary for PoolId;

    // Address of the lending pool
    address public lendingPool;

    mapping(PoolId poolId => int24 tickLower) public tickLowerLasts;

    struct LiquidityRange {
        int24 tickLower; // The lower tick of the range
        int24 tickUpper; // The upper tick of the range
    }

    // The key is the pool ID (bytes32), which is derived from the PoolKey using the toPoolId() function.
    // The value is the LiquidityRange struct that represents the range of ticks where liquidity has been provided.
    mapping(bytes32 => LiquidityRange) public liquidityRanges;

    // Initialize BaseHook and ERC1155 parent contracts in the constructor
    constructor(
        IPoolManager _poolManager,
        string memory _uri,
        address _lendingPool
    ) ERC1155(_uri) BaseHook(_poolManager) {
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
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false
            });
    }

    // Hooks
    function beforeSwap(
        address,
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        LiquidityRange memory range = liquidityRanges[poolKey.toPoolId()];

        uint256 currentPrice = convertSqrtPriceX96ToPrice(poolKey.sqrtPriceX96);

        if (currentPrice < range.tickLower || currentPrice > range.tickUpper) {
            // If it is outside the range, get all the liquidity provided
            uint256 liquidityToRetrieve = _retrieveLiquidity(
                poolKey.toPoolId()
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
        LiquidityRange memory range = liquidityRanges[poolKey.toPoolId()];

        uint256 currentPrice = convertSqrtPriceX96ToPrice(poolKey.sqrtPriceX96);

        if (currentPrice < range.tickLower || currentPrice > range.tickUpper) {
            // If it is outside the range, get all the liquidity provided
            uint256 liquidityToRetrieve = _retrieveLiquidity(
                poolKey.toPoolId()
            );

            // Deposit the retrieved liquidity in the lending pool
            depositInLendingPool(liquidityToRetrieve);
        }

        return BaseHook.afterSwap.selector;
    }

    // Helper functions
    function _setTickLowerLast(PoolId poolId, int24 tickLower) private {
        tickLowerLasts[poolId] = tickLower;
    }

    function _getTickLower(
        int24 actualTick,
        int24 tickSpacing
    ) private pure returns (int24) {
        int24 intervals = actualTick / tickSpacing;

        if (actualTick < 0 && (actualTick % tickSpacing) != 0) {
            intervals--;
        }

        return intervals * tickSpacing;
    }

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
}
