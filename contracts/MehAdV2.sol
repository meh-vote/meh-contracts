// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERCAd} from "./ERCAd/IERCAd.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehAdV2 is CCIPReceiver, Ownable {
    uint256 private constant WHALE_AMT = 500000 * 10 ** 18;
    uint256 private constant DEFAULT_AMT = 50000 * 10 ** 18;

    address public mainnetContractAddress;
    IRouterClient public router;
    IERC20 public mehToken;
    IERC20 public linkToken;
    IERCAd public ercAdContract;
    uint64 public destinationChainSelector;

    event MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender, uint256 balance);
    event MessageSent(bytes32 messageId);
    event ErrorOccurred(string reason);

    constructor(
        address _mainnetContractAddress,
        address _router,
        address _linkTokenAddress,
        address _mehTokenAddress,
        address _ercAdAddress,
        uint64 _destinationChainSelector
    ) CCIPReceiver(_router) {
        mainnetContractAddress = _mainnetContractAddress;
        router = IRouterClient(_router);
        mehToken = IERC20(_mehTokenAddress);
        linkToken = IERC20(_linkTokenAddress);
        ercAdContract = IERCAd(_ercAdAddress);
        destinationChainSelector = _destinationChainSelector;
    }

    function sendWalletAddress() public {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](0);
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(mainnetContractAddress),
            data: abi.encode(msg.sender),
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 400_000}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: address(0)
        });

        uint256 fee = router.getFee(destinationChainSelector, message);

        try router.ccipSend{value: fee}(destinationChainSelector, message) returns (bytes32 messageId) {
            emit MessageSent(messageId);
        } catch Error(string memory reason) {
            emit ErrorOccurred(reason);
        } catch {
            emit ErrorOccurred("Unknown error occurred");
        }
    }

    function _ccipReceive(Client.Any2EVMMessage memory message) internal override {
        uint256 balance = abi.decode(message.data, (uint256));
        address sender = abi.decode(message.sender, (address));

        balance += linkToken.balanceOf(address(this));

        uint256 amtToTransfer = DEFAULT_AMT;
        if (balance >= (1 * 10 ** 18)) {
            amtToTransfer += WHALE_AMT;
        }
        mehToken.transfer(msg.sender, amtToTransfer);

        emit MessageReceived(message.messageId, message.sourceChainSelector, sender, balance);
    }

    function signAd(uint256 id, bytes32[] calldata proof) external {
        ercAdContract.signAd(id, proof);
        sendWalletAddress();
    }

    function displayAd(uint256 id) external view returns (IERCAd.Ad memory) {
        return ercAdContract.displayAd(id);
    }

    function withdrawMeh() external onlyOwner {
        uint256 balance = mehToken.balanceOf(address(this));
        mehToken.transfer(owner(), balance);
    }
}