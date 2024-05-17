// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERCAd {
    struct Ad {
        string adURI;
        string dataURI; // ipfs URI to views data
        bytes32 signatureRoot; // merkleRoot of signers
        bytes32 audienceRoot; // merkleRoot of target audience
    }

    function setAd(
        string memory adURI,
        string memory dataURI,
        bytes32 signatureRoot,
        bytes32 audienceRoot
    ) external;

    function signAd(
        uint256 id,
        bytes32[] calldata proof
    ) external;

    function displayAd(
        uint256 id
    ) external view returns (Ad memory);

    function hasSignedAd(
        uint256 id,
        bytes32[] calldata proof
    ) external view returns (bool);

    function isInAudience(
        uint256 id,
        bytes32[] calldata proof
    ) external view returns (bool);
}