// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERCAd.sol";

contract MehNetworkV1 is ERCAd {
    constructor(string memory name, string memory symbol) ERCAd(name, symbol) {}


    function signAd() public pure override {
        // pay bounty if in audience
        // record merkle root
    }
}