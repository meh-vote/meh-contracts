// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehCCIPReceiver is CCIPReceiver, Ownable {
    uint256 private constant WHALE_AMT = 500000 * 10 ** 18;
    uint256 private constant DEFAULT_AMT = 50000 * 10 ** 18;
    IERC20 public mehToken;
    IRouterClient public router;

    event MessageReceived(
        bytes32 messageId,
        address sender,
        uint256 linkBalance
    );

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
        address _router,
        address _mehTokenAddress
    ) CCIPReceiver(_router) {
        router = IRouterClient(_router);
        mehToken = IERC20(_mehTokenAddress);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        bytes32 messageId = any2EvmMessage.messageId; // fetch the messageId
        address sender = abi.decode(any2EvmMessage.sender, (address)); // abi-decoding of the sender address
        CrossChainCapital memory message = abi.decode(any2EvmMessage.data, (CrossChainCapital)); // abi-decoding of the sent string message

        uint256 amtToTransfer = DEFAULT_AMT;
        if (message.link >= (1 * 10 ** 18)) {
            amtToTransfer += WHALE_AMT;
        }
        mehToken.transfer(msg.sender, amtToTransfer);

        emit MessageReceived(messageId, sender, message.link);
    }

    function withdrawMeh() external onlyOwner {
        uint256 balance = mehToken.balanceOf(address(this));
        mehToken.transfer(owner(), balance);
    }
}