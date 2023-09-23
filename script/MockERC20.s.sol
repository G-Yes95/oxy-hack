pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/mocks/MockERC20.sol";

contract MockERC20Deployer is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        MockERC20 hETH = new MockERC20("hETH", "hackETH", 18);
        vm.stopBroadcast();
        console2.log(address(hETH), "deployed mock token");
    }
}
