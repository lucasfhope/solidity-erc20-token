// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {HopeToken} from "src/HopeToken.sol";

contract DeployHopeToken is Script {
    uint256 private constant INITIAL_SUPPLY = 100 ether;

    function run() external returns (HopeToken) {
        vm.startBroadcast();
        HopeToken hopeToken = new HopeToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return hopeToken;
    }
}
