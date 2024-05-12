// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERCProjector.sol";

contract MehNetworkV1 is ERCProjector {
    constructor(string memory name, string memory symbol) ERCProjector(name, symbol) {}


    function signAd() public pure override {
        // pay bounty if in audience
        // record merkle root
    }
}