// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MehV1 is Ownable, ReentrancyGuard {
    IERC20 public immutable mehToken;
    uint256 public constant MEH_MULTIPLIER = 1000;

    using Counters for Counters.Counter;
    Counters.Counter private mehIds;
    uint256 lastMehDistributed = 0;

    struct Meh {
        string name;
        string link;
        string media;
        address creator;
        uint256 begin;
        uint256 end;
        uint256 amt;
        uint256 meh;
        uint256 total;
        bool isMeh;
    }

    mapping(uint256 => Meh) public meh;

    constructor(IERC20 _mehToken) {
        mehToken = _mehToken;
    }

    function isMeh(uint256 mehId) public view returns (bool) {
        Meh storage entry = meh[mehId];
        return entry.meh > (entry.total / 2);
    }

    function mehNeeded() public view returns (uint256) {
        uint256 futureMeh = 1;
        for (uint256 i = lastMehDistributed; i < mehIds.current(); i++) {
            if (meh[i].end >= block.timestamp) {
                futureMeh++;
            }
        }
        return futureMeh * futureMeh * MEH_MULTIPLIER;
    }

    function makeMeh(
        string memory name,
        string memory link,
        string memory media
    ) external nonReentrant {
        uint256 mehNeededToMakeMeh = mehNeeded();
        require(mehToken.transferFrom(msg.sender, address(this), mehNeededToMakeMeh));

        // Create the new Meh entry
        uint256 newId = mehIds.current();
        Meh storage newMeh = meh[newId];
        newMeh.name = name;
        newMeh.link = link;
        newMeh.media = media;
        newMeh.creator = msg.sender;
        newMeh.amt = mehNeededToMakeMeh;
        newMeh.begin = meh[mehIds.current()].end + 1 days;
        newMeh.end = newMeh.begin + 1 days;

        mehIds.increment();
    }


    function distribute(uint256 mehId) external {
        //
    }

}
