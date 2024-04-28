// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Meh is ERC20, Ownable {
    uint256 public constant MEH_SUPPLY = 1_000_000_000_000 * (10 ** 18); // 1 trillion meh

    constructor() ERC20("Meh", "Meh") {

    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MEH_SUPPLY, "meh");
        _mint(to, amount);
    }
}
