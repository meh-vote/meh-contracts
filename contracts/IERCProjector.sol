// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERCProjector {
    function setAd(
        string memory adURI,
        string memory dataURI,
        string memory signatureRoot,
        string memory audienceRoot
    ) external;

    function signAd() external pure;

}