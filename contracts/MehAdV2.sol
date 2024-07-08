// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERCAd} from "./ERCAd/IERCAd.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehAdV2 is Ownable {
    address public baseContractAddress;
    IRouterClient public router;
    IERC20 public linkToken;
    IERCAd public ercAdContract;
    uint64 public destinationChainSelector;

    struct CrossChainCapital {
        uint256 eth;
        uint256 link;
    }

    struct Message {
        uint64 sourceChainSelector;
        address sender;
        CrossChainCapital message;
    }

    event MessageSent(
        bytes32 messageId,
        address sender,
        uint256 fees,
        uint256 linkBalance
    );

    constructor(
        address _baseContractAddress,
        address _router,
        address _linkTokenAddress,
        address _ercAdAddress,
        uint64 _destinationChainSelector
    ) {
        baseContractAddress = _baseContractAddress;
        router = IRouterClient(_router);
        linkToken = IERC20(_linkTokenAddress);
        ercAdContract = IERCAd(_ercAdAddress);
        destinationChainSelector = _destinationChainSelector;
    }

    function sendMessage(
        CrossChainCapital memory message
    ) public returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(baseContractAddress),
            data: abi.encode(message),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 400_000})
            ),
            feeToken: address(0)
        });

        uint256 fees = router.getFee(destinationChainSelector, evm2AnyMessage);

        messageId = router.ccipSend{value: fees}(
            destinationChainSelector,
            evm2AnyMessage
        );

        emit MessageSent(messageId, msg.sender, fees, message.link);

        return messageId;
    }

    function signAd(uint256 id, bytes32[] calldata proof) external {
        ercAdContract.signAd(id, proof);

        uint256 ethBalance = address(this).balance;
        uint256 linkBalance = linkToken.balanceOf(msg.sender);

        CrossChainCapital memory capital = CrossChainCapital({
            eth: ethBalance,
            link: linkBalance
        });

        sendMessage(capital);
    }

    function displayAd(uint256 id) external view returns (IERCAd.Ad memory) {
        return ercAdContract.displayAd(id);
    }

    receive() external payable {}
}