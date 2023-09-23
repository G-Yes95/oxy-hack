// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {LendingPool} from "./LendingPool.sol";
import {WadRayMath} from "./WadRayMath.sol";
import {PercentageMath} from "./PercentageMath.sol";

contract InterestRateStrategy {
    using WadRayMath for uint256;
    using PercentageMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    /**
     * @notice Returns the usage ratio at which the pool aims to obtain most competitive borrow rates.
     * @return The optimal usage ratio, expressed in ray.
     */
    uint256 public immutable OPTIMAL_USAGE_RATIO;

    /**
     * @notice Returns the excess usage ratio above the optimal.
     * @dev It's always equal to 1-optimal usage ratio (added as constant for gas optimizations)
     * @return The max excess usage ratio, expressed in ray.
     */
    uint256 public immutable MAX_EXCESS_USAGE_RATIO;

    // Base stable borrow rate when usage rate = 0. Expressed in ray
    uint256 internal immutable _baseStableBorrowRate;

    // Slope of the stable interest curve when usage ratio > 0 and <= OPTIMAL_USAGE_RATIO. Expressed in ray
    uint256 internal immutable _stableRateSlope1;

    // Slope of the variable interest curve when usage ratio > OPTIMAL_USAGE_RATIO. Expressed in ray
    uint256 internal immutable _stableRateSlope2;

    struct CalcInterestRatesLocalVars {
        uint256 availableLiquidity;
        uint256 currentStableBorrowRate;
        uint256 currentLiquidityRate;
        uint256 usageRatio;
        uint256 availableLiquidityPlusDebt;
        uint256 couponPremiumRate;
        uint256 collateralInsurancePremiumRate;
    }
}
