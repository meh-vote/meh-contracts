// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERCAd/ERCAd.sol";

contract MehNetworkV1 is ERCAd {
    constructor(string memory name, string memory symbol) ERCAd(name, symbol) {}


    function signAd(uint256 id, bytes32[] calldata proof) public override {
        // pay bounty if in audience
        super.signAd(id, proof);
    }
}