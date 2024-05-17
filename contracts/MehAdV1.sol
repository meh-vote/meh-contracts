import "./ERCAd/ERCAd.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MehAdV1 is ERCAd {
    IERC20 public mehToken;
    mapping(address => uint256) public discounts;

    constructor(string memory name, string memory symbol, address mehTokenAddress) ERCAd(name, symbol) {
        mehToken = IERC20(mehTokenAddress);
    }

    function signAd(uint256 id, bytes32[] calldata proof) public override {
        super.signAd(id, proof);
        applyDiscount(id);
        mehToken.transfer(msg.sender, 50000 * 10 ** 18);
    }

    function applyDiscount(uint256 adId) internal {
        discounts[msg.sender] = 20;
    }
}



