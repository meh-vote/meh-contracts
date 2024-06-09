import "./ERCAd/ERCAd.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MehAdV1 is ERCAd {
    IERC20 public mehToken;
    mapping(address => uint256) public discounts;
    uint256 private constant MAX_AMT = 250000 * 10 ** 18;
    mapping(address => bool) public hasSigned;

    constructor(string memory name, string memory symbol, address mehTokenAddress) ERCAd(name, symbol) {
        mehToken = IERC20(mehTokenAddress);
    }

    function signAd(uint256 id, bytes32[] calldata proof) public override {
        require(!hasSigned[msg.sender], "Already signed an ad");

        super.signAd(id, proof);
        (uint256 amtToTransfer, ) = adAmt();

        mehToken.transfer(msg.sender, amtToTransfer);
        hasSigned[msg.sender] = true;
    }


    function adAmt() public view returns (uint256, uint256) {
        uint256 ethBalance = msg.sender.balance;
        uint256 amtToTransfer = (10000 + (ethBalance / 1 ether) * 100000) * 1 ether;

        if (amtToTransfer > MAX_AMT) {
            amtToTransfer = MAX_AMT;
        }
        return (amtToTransfer, ethBalance);
    }
}
