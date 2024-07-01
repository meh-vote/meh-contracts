// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MehCCIPLink is CCIPReceiver {
    IERC20 public linkToken;
    IRouterClient public router;
    uint64 public sourceChainSelector;
    address public sourceContractAddress;

    event MessageSent(bytes32 messageId);
    event ErrorOccurred(string reason);

    constructor(
        address _linkAddress,
        address _router,
        uint64 _sourceChainSelector,
        address _sourceContractAddress
    ) CCIPReceiver(_router) {
        linkToken = IERC20(_linkAddress);
        router = IRouterClient(_router);
        sourceChainSelector = _sourceChainSelector;
        sourceContractAddress = _sourceContractAddress;
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        uint256 linkBalance = linkToken.balanceOf(address(this));
        bytes memory data = abi.encode(linkBalance);

        Client.EVM2AnyMessage memory response = Client.EVM2AnyMessage({
            receiver: abi.encodePacked(sourceContractAddress),
            data: data,
            tokenAmounts: new Client.EVMTokenAmount ,
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
}