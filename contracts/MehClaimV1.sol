// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehClaimV1 is ReentrancyGuard, Ownable {
    IERC20 public immutable mehToken;

    uint256 public constant MIN_TOKEN_AMOUNT = 700 * 10**18;
    uint256 public constant MAX_TOKEN_AMOUNT = 1100 * 10**18;
    uint256 public constant TIME_INTERVAL = 1 days;

    mapping(address => uint256) public lastAccessTime;
    bool public faucetOn;

    constructor(IERC20 _mehToken) {
        mehToken = _mehToken;
        faucetOn = false;
    }

    function randomMeh() private view returns (uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.prevrandao, block.timestamp, msg.sender))) % (MAX_TOKEN_AMOUNT - MIN_TOKEN_AMOUNT + 1);
        return random + MIN_TOKEN_AMOUNT;
    }

    function faucet() external nonReentrant {
        require(faucetOn, "meh");
        require(block.timestamp >= lastAccessTime[msg.sender] + TIME_INTERVAL, "meh");
        uint256 amount = randomMeh();
        require(mehToken.balanceOf(address(this)) >= amount, "meh");

        lastAccessTime[msg.sender] = block.timestamp;
        mehToken.transfer(msg.sender, amount);
    }

    function toggleFaucet() external onlyOwner {
        faucetOn = !faucetOn;
    }
}