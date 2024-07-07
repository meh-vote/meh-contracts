// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehCrossChain is CCIPReceiver, Ownable {
    IERC20 public linkToken;
    IRouterClient public router;
    uint64 public sourceChainSelector;
    address public sourceContractAddress;

    event MessageSent(bytes32 messageId);
    event MessageReceived(
        bytes32 messageId,
        address sender
    );
    event ErrorOccurred(string reason);

    struct CrossChainCapital {
        uint256 eth;
        uint256 link;
    }

    struct Message {
        uint64 sourceChainSelector;
        address sender;
        CrossChainCapital message;
    }

    constructor(
        address _linkAddress,
        address _router,
        uint64 _sourceChainSelector
    ) CCIPReceiver(_router) {
        linkToken = IERC20(_linkAddress);
        router = IRouterClient(_router);
        sourceChainSelector = _sourceChainSelector;
    }

    function setSourceContractAddress(address _sourceContractAddress) external onlyOwner {
        sourceContractAddress = _sourceContractAddress;
    }

    /// handle a received message
    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        bytes32 messageId = any2EvmMessage.messageId; // fetch the messageId
        uint64 sourceChainSelector = any2EvmMessage.sourceChainSelector; // fetch the source chain identifier (aka selector)
        address sender = abi.decode(any2EvmMessage.sender, (address)); // abi-decoding of the sender address
        //CrossChainCapital memory message = abi.decode(any2EvmMessage.data, (CrossChainCapital)); // abi-decoding of the sent string message


        emit MessageReceived(messageId, sender);
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
}