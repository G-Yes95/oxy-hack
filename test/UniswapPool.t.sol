// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PoolKey} from "../lib/v4-core/contracts/types/PoolKey.sol";
import {IPoolManager} from "../lib/v4-core/contracts/interfaces/IPoolManager.sol";

import "forge-std/Test.sol";
import "../src/UniswapPool.sol";
import {LendingHook} from "../src/LendingHook.sol";
import "../src/lendingPool/LendingPool.sol";
import "../lib/v4-core/contracts/PoolManager.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../src/mocks/MockERC20.sol";
import "./HookMiner.sol";
import {IPoolManager} from "../lib/v4-core/contracts/interfaces/IPoolManager.sol";
import {Currency} from "../lib/v4-core/contracts/types/Currency.sol";
import {Hooks} from "../lib/v4-core/contracts/libraries/Hooks.sol";
import "../src/lendingPool/InterestRateStrategy.sol";

contract UniswapPoolTest is Test {
    UniswapPool public uniswapPool;
    PoolManager public poolManager;
    MockERC20 public collateralToken;
    MockERC20 public stableToken;
    LendingPool public lendingPool;
    LendingHook public lendingHook;
    InterestRateStrategy public interestRateStrategy;
    address user2 = address(1);

    function setUp() public {
        collateralToken = new MockERC20("CT", "CT", 18);
        stableToken = new MockERC20("ST", "ST", 18);
        collateralToken.mint(address(this), 1 ether);
        stableToken.mint(address(this), 1 ether);
        poolManager = new PoolManager(100);
        uniswapPool = new UniswapPool(
            poolManager,
            address(stableToken),
            address(collateralToken)
        );
        interestRateStrategy = new InterestRateStrategy(70, 10, 90, 300);

        lendingPool = new LendingPool(
            address(stableToken),
            address(0),
            address(0),
            address(interestRateStrategy)
        );

        // Deploy the hook to an address with the correct flags
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG);
        (address hookAddress, bytes32 salt) = HookMiner.find(
            address(this),
            flags,
            0,
            type(LendingHook).creationCode,
            abi.encode(
                address(poolManager),
                address(lendingPool),
                address(uniswapPool)
            )
        );

        lendingHook = new LendingHook{salt: salt}(
            poolManager,
            address(lendingPool),
            address(uniswapPool)
        );
        require(
            address(lendingHook) == hookAddress,
            "CounterTest: hook address mismatch"
        );

        lendingHook.setUserAddress(address(this), user2);

        // IPoolManager _poolManager,
        // address _lendingPool,
        // IUniswapPool _uniswapPool

        // address _stableCoin,
        // address _principalToken,
        // address _loanRouter,
        // address _interestRateStrategy
    }

    function testSwapHookSendsToLendingPool() external {
        // deposit into UniPool
        stableToken.approve(address(uniswapPool), 100);
        collateralToken.approve(address(uniswapPool), 100);
        uniswapPool.depositLiquidity(100, 50, 1, 33333);
        assertEq(stableToken.balanceOf(address(uniswapPool)), 100);
        (int24 tickLower, int24 tickUpper) = uniswapPool.liquidityRanges(
            address(this)
        );
        console.log("UniswapPool balance before swap:");
        console.log(stableToken.balanceOf(address(uniswapPool)));
        console.log("LendingPool balance before swap:");
        console.log(stableToken.balanceOf(address(lendingPool)));
        // Swap
        PoolKey memory poolKey = PoolKey(
            Currency.wrap(address(stableToken)),
            Currency.wrap(address(0)),
            0,
            8888,
            lendingHook
        );

        IPoolManager.SwapParams memory swapParams = IPoolManager.SwapParams(
            true,
            10,
            0
        );
        uniswapPool.swapTokens(poolKey, swapParams, 10341231230);
        console.log("============");
        console.log("UniswapPool balance after swap:");
        console.log(stableToken.balanceOf(address(uniswapPool)));

        console.log("LendingPool balance after swap:");
        console.log(stableToken.balanceOf(address(lendingPool)));
        lendingHook.setPrice(99232123823359799118286999568);
        uniswapPool.swapTokens(poolKey, swapParams, 10341231230);

        console.log("LendingPool balance after swap:");
        console.log(stableToken.balanceOf(address(lendingPool)));
    }
}
