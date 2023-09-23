pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
// import "@buttonwood-protocol/button-wrappers/contracts/ButtonToken.sol";
// import "@buttonwood-protocol/button-wrappers/contracts/ButtonTokenFactory.sol";
// import "@buttonwood-protocol/button-wrappers/contracts/oracles/ChainlinkOracle.sol";


// contract ButtonDeployer is Script {
//     function setUp() public {}

//     function run() public {

//         vm.startBroadcast();

//         ButtonToken buttonTemplate = new ButtonToken(); 
//         ButtonTokenFactory buttonFactory = new ButtonTokenFactory(address(buttonTemplate)); 
        
//         ChainlinkOracle btc = new ChainlinkOracle(0xAC15714c08986DACC0379193e22382736796496f, 96400); 
//         ChainlinkOracle eth = new ChainlinkOracle(0xcD2A119bD1F7DF95d706DE6F2057fDD45A0503E2, 96400); 

        
//         vm.stopBroadcast();

//         console2.log(address(btc), "deployed buttonTemplate");
//         console2.log(address(eth), "deployed buttonFactory");

//     }
// }