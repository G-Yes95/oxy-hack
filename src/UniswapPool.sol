// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

error SwapExpired();
error OnlyPoolManager();

using CurrencyLibrary for Currency;
using SafeERC20 for IERC20;

contract UniswapPool {
    IPoolManager public poolManager;

    constructor(IPoolManager _poolManager) {
        poolManager = _poolManager;
    }

    function swapTokens(
        PoolKey calldata poolKey,
        IPoolManager.SwapParams calldata swapParams,
        uint256 deadline
    ) public payable {
        poolManager.lock(abi.encode(poolKey, swapParams, deadline));
    }

    function lockAcquired(
        uint256,
        bytes calldata data
    ) external returns (bytes memory) {
        if (msg.sender == address(poolManager)) {
            revert OnlyPoolManager();
        }

        (
            PoolKey memory poolKey,
            IPoolManager.SwapParams memory swapParams,
            uint256 deadline
        ) = abi.decode(data, (PoolKey, IPoolManager.SwapParams, uint256));

        if (block.timestamp > deadline) {
            revert SwapExpired();
        }

        BalanceDelta delta = poolManager.swap(poolKey, swapParams, hookData);

        _settleCurrencyBalance(poolKey.currency0, delta.amount0());
        _settleCurrencyBalance(poolKey.currency1, delta.amount1());

        return new bytes(0);
    }

    function _settleCurrencyBalance(
        Currency currency,
        int128 deltaAmount
    ) private {
        if (deltaAmount < 0) {
            poolManager.take(currency, msg.sender, uint128(-deltaAmount));
            return;
        }

        if (currency.isNative()) {
            poolManager.settle{value: uint128(deltaAmount)}(currency);
            return;
        }

        IERC20(Currency.unwrap(currency)).safeTransferFrom(
            msg.sender,
            address(poolManager),
            uint128(deltaAmount)
        );
        poolManager.settle(currency);
    }
}
