// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehCCIPLink is CCIPReceiver, Ownable {
    IERC20 public linkToken;
    IRouterClient public router;
    uint64 public sourceChainSelector;
    address public sourceContractAddress;

    event MessageSent(bytes32 messageId);
    event ErrorOccurred(string reason);

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

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        address sender = abi.decode(message.sender, (address));
        uint256 linkBalance = linkToken.balanceOf(sender);
        bytes memory data = abi.encode(linkBalance);
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](0);

        Client.EVM2AnyMessage memory response = Client.EVM2AnyMessage({
            receiver: abi.encodePacked(sourceContractAddress),
            data: data,
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: address(0)
        });

        uint256 fee = router.getFee(sourceChainSelector, response);

        try router.ccipSend{value: fee}(sourceChainSelector, response) returns (bytes32 messageId) {
            emit MessageSent(messageId);
        } catch Error(string memory reason) {
            emit ErrorOccurred(reason);
        } catch {
            emit ErrorOccurred("Unknown error occurred");
        }
    }

    function withdrawETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    receive() external payable {}
}