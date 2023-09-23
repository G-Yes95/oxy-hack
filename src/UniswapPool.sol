// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@uniswap/v4-core/contracts/interfaces/IUniswapV4Factory.sol";
import "@uniswap/v4-core/contracts/interfaces/IUniswapV4Pool.sol";
import "@uniswap/v4-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapPool {
    address private _owner;
    IUniswapV4Factory public uniswapV4Factory;
    ISwapRouter public uniswapV4Router;
    IERC20 public tokenA;
    IERC20 public tokenB;
    IUniswapV4Pool public pool;
    uint24 public constant POOL_FEE = 3000; // 0.3% fee

    constructor(
        address _uniswapV4Factory,
        address _uniswapV4Router,
        address _tokenA,
        address _tokenB
    ) {
        _owner = msg.sender;
        uniswapV4Factory = IUniswapV4Factory(_uniswapV4Factory);
        uniswapV4Router = ISwapRouter(_uniswapV4Router);
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function createPool() external {
        require(msg.sender == owner, "Not authorized");
        uniswapV4Factory.createPool(address(tokenA), address(tokenB), poolFee);
        pool = IUniswapV4Pool(
            uniswapV4Factory.getPool(address(tokenA), address(tokenB), poolFee)
        );
    }

    function addLiquidityInRange(
        uint256 amountA,
        uint256 amountB,
        int24 tickLower,
        int24 tickUpper
    ) external {
        // Approve the pool to transfer tokens on behalf of the liquidity provider
        tokenA.approve(address(pool), amountA);
        tokenB.approve(address(pool), amountB);

        // Parameters for the mint function
        address recipient = msg.sender;
        uint128 liquidityAmount = uint128(amountA); // This is a simplification; in reality, you'd calculate the liquidity amount based on the amounts of tokenA and tokenB and the current price.

        // Call the mint function on the pool
        pool.mint(recipient, tickLower, tickUpper, liquidityAmount, "");
    }
}
