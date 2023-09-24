// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/UniswapPool.sol";
import "../lib/v4-core/contracts/PoolManager.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/mocks/MockERC20.sol";

contract CounterTest is Test {
    UniswapPool public uniswapPool;
    PoolManager public poolManager;
    MockERC20 public collateralToken;
    MockERC20 public stableToken;
    
    function setUp() public {
        collateralToken = new MockERC20("CT", "CT", 18);
        stableToken = new MockERC20("ST", "ST", 18);
        poolManager = new PoolManager(100);
        uniswapPool = new UniswapPool(poolManager, address(collateralToken), address(stableToken));
    }

    function testSwapHookSendsToLendingPool() external{
        // swap should trigger deposit to lendingPool

    }
}
