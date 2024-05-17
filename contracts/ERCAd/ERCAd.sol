// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./IERCAd.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract ERCAd is IERCAd, ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _adIds;

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
        bytes32 signatureRoot,
        bytes32 audienceRoot
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


    function signAd(uint256 id, bytes32[] calldata proof) public virtual {
        require(_exists(id), "ERC721: ad does not exist");

        Ad storage ad = ads[id];
        require(!hasSignedAd(id, proof), "Sender already signed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, bytes32(ad.signatureRoot), leaf), "Sender already signed");


        bytes memory signatures = abi.encodePacked(ad.signatureRoot, msg.sender);
        ad.signatureRoot = keccak256(signatures);
    }

    function displayAd(uint256 id) public view returns (Ad memory) {
        return ads[id];
    }

    function isInAudience(uint256 id, bytes32[] calldata proof) public view returns (bool) {
        require(_exists(id), "ERC721: ad does not exist");

        Ad storage ad = ads[id];
        if (ad.audienceRoot != bytes32(0)) {
            bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
            return MerkleProof.verify(proof, bytes32(ad.audienceRoot), leaf);
        }
        return true;
    }

    function hasSignedAd(uint256 id, bytes32[] calldata proof) public view returns (bool) {
        require(_exists(id), "ERC721: ad does not exist");

        Ad storage ad = ads[id];
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        return MerkleProof.verify(proof, bytes32(ad.signatureRoot), leaf);
    }

}