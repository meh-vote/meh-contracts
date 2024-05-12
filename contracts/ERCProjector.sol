// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IERCProjector.sol";

contract ERCProjector is IERCProjector, ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _adIds;

    struct Ad {
        string adURI;
        string dataURI; // ipfs URI to views data
        string signatureRoot; // merkleroot of signed msgs
        string audienceRoot; // merkleroot of target audience
    }

    Ad private activeAd;
    mapping(uint256 => Ad) private ads;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return activeAd.adURI;
    }

    function setAd(
        string memory adURI,
        string memory dataURI,
        string memory signatureRoot,
        string memory audienceRoot
    ) public onlyOwner {
        _adIds.increment();
        uint256 adId = _adIds.current();
        ads[adId] = Ad({
            adURI: adURI,
            dataURI: dataURI,
            signatureRoot: signatureRoot,
            audienceRoot: audienceRoot
        });
        _mint(msg.sender, adId);
        activeAd = ads[adId];
    }


    function signAd() public pure virtual override {
        // Implementation needed
    }
}