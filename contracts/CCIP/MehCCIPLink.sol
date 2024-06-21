// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MehCCIPLink {
    uint256 public linkBalance;

    constructor(uint256 _linkBalance) {
        linkBalance = _linkBalance;
    }

    function getLinkBalance() external view returns (uint256) {
        return linkBalance;
    }
}