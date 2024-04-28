// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

contract MehRoyalty is ERC721, Ownable {
    uint256 public constant MEH_ROYALTY_DENOMINATOR = 1000;
    string private _baseTokenURI;
    IERC20Burnable public immutable mehToken;

    struct MehRoyaltyData {
        uint256 royaltyNumerator;
        uint256 royaltyDenominator;
        uint256 productId;
        uint256 mehDeposited;
    }

    mapping(uint256 => MehRoyaltyData) public royalties;

    constructor(IERC20Burnable _mehToken) ERC721("MehRoyalty", "MR1") {
        mehToken = _mehToken;
    }

    function mint(
        uint256 tokenId,
        uint256 royaltyValue,
        uint256 productId,
        address to
    ) external onlyOwner {
        _mint(to, tokenId);
        royalties[tokenId] = MehRoyaltyData({
            royaltyNumerator: royaltyValue,
            royaltyDenominator : MEH_ROYALTY_DENOMINATOR,
            productId: productId,
            mehDeposited: 0
        });
    }

    function depositMeh(uint256 tokenId) external payable {
        require(_exists(tokenId), "token does not exist");
        royalties[tokenId].mehDeposited += msg.value;
    }

    function extractMeh(uint256 tokenId, uint256 amount) external {
        require(ownerOf(tokenId) == msg.sender, "caller is not the owner of the token");
        require(royalties[tokenId].mehDeposited >= amount, "insufficient meh");

        royalties[tokenId].mehDeposited -= amount;
        payable(msg.sender).transfer(amount);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
}