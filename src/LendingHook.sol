// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {BaseHook} from "@uniswap/v4-periphery/contracts/BaseHook.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";

contract LendingHook is BaseHook, ERC1155 {
    using PoolIdLibrary for PoolId;

    mapping(PoolId poolId => int24 tickLower) public tickLowerLasts;

    // Initialize BaseHook and ERC1155 parent contracts in the constructor
    constructor(
        IPoolManager _poolManager,
        string memory _uri
    ) ERC1155(_uri) BaseHook(_poolManager) {}

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
    function beforeSwap();

    function afterSwap();

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
}
