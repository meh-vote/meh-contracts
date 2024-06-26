// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

contract MehCCIPLink {
    IERC20 public linkToken;

    constructor(address _linkAddress) {
        linkToken = IERC20(_linkAddress);
    }

    function getLinkBalance() external view returns (uint256) {
        return linkToken.balanceOf(address(this));
    }
}