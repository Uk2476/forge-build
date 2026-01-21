//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import "src/tokens.sol";
import "src/week3Amm.sol";
import {Script} from "forge-std/Script.sol";

contract DeployAmmScript is Script {
    function run() public returns (amm) {
        vm.startBroadcast();
        amm Amm = new amm();
        vm.stopBroadcast();
        
        // Log important addresses
        console.log("AMM deployed at:", address(Amm));
        console.log("StudyPoint token:", address(Amm.studypoint()));
        console.log("CanteenToken:", address(Amm.canteenToken()));
        
        return Amm;
    }
}

