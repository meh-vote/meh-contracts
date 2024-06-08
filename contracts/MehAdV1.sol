import "./ERCAd/ERCAd.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MehAdV1 is ERCAd {
    IERC20 public mehToken;
    mapping(address => uint256) public discounts;
    uint256 MAX_AMT = 1000000 * 10 ** 18;

    constructor(string memory name, string memory symbol, address mehTokenAddress) ERCAd(name, symbol) {
        mehToken = IERC20(mehTokenAddress);
    }

    function signAd(uint256 id, bytes32[] calldata proof) public override {
        super.signAd(id, proof);

        uint256 ethBalance = msg.sender.balance;
        uint256 amtToTransfer = (10000 + (ethBalance * 100000) * 10 ** 18);

        if (amtToTransfer > MAX_AMT) {
            amtToTransfer = MAX_AMT;
        }

        mehToken.transfer(msg.sender, amtToTransfer);
    }
}
