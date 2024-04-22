// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehAirdropV1 is Ownable {
    using SafeERC20 for IERC20;
    IERC20 public immutable meh;

    constructor(IERC20 _meh) {
        meh = _meh;
    }

    function airdrop(address[] memory _contributors, uint256[] memory _balances) external onlyOwner payable {
        uint8 i = 0;
        for (i; i < _contributors.length; i++) {
            meh.safeTransfer(_contributors[i], _balances[i]);
        }
    }

    // withdraw MEH from contract
    function withdrawMeh(uint256 amount) external onlyOwner {
        meh.safeTransfer(msg.sender, amount);
    }
}