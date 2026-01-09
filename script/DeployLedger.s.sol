//SPDX_License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {Ledger} from "../src/Ledger.sol";

contract DeployLedger is Script {
    function run() public {
        vm.startBroadcast();
        Ledger ledger = new Ledger();
        vm.stopBroadcast();
    }
}
