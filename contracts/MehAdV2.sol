// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "./ERCAd/ERCAd.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MehAdV2 is CCIPReceiver, ERCAd {
    IERC20 public mehToken;
    uint256 private constant WHALE_AMT = 250000 * 10 ** 18;
    uint256 private constant DEFAULT_AMT = 500000 * 10 ** 18;
    mapping(address => bool) public hasSigned;

    address public mainnetContractAddress;
    IRouterClient public router;
    address public linkToken;

    event MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender, uint256 balance);
    event MessageSent(bytes32 messageId);

    constructor(
        address _mainnetContractAddress,
        address _router,
        address _linkToken,
        string memory name,
        string memory symbol,
        address mehTokenAddress
    ) CCIPReceiver(_router) ERCAd(name, symbol) {
        mainnetContractAddress = _mainnetContractAddress;
        router = IRouterClient(_router);
        linkToken = _linkToken;
        mehToken = IERC20(mehTokenAddress);
    }

    function signAd(uint256 id, bytes32[] calldata proof) public override {
        require(!hasSigned[msg.sender], "already signed ad");
        super.signAd(id, proof);
        hasSigned[msg.sender] = true;
    }

    function getLinkBalance() public {
        bytes memory data = abi.encodeWithSignature("getLinkBalance()");
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](0);
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(mainnetContractAddress),
            data: data,
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: address(0)
        });

        uint256 fee = router.getFee(0 /*destinationChainSelector*/, message);
        bytes32 messageId = router.ccipSend{value: fee}(0 /*destinationChainSelector*/, message);

        emit MessageSent(messageId);
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        uint256 balance = abi.decode(message.data, (uint256));
        address sender = abi.decode(message.sender, (address));

        uint256 amtToTransfer = DEFAULT_AMT;
        if (balance > 1) {
            amtToTransfer += WHALE_AMT;
        }
        mehToken.transfer(msg.sender, amtToTransfer);

        emit MessageReceived(message.messageId, message.sourceChainSelector, sender, balance);
    }
}