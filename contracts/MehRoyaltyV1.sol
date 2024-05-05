// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract MehRoyaltyV1 is ERC721, Ownable, ReentrancyGuard {
    string private baseTokenURI;
    IERC20 public immutable mehToken;
    address public MINTER_ADDRESS;

    constructor(IERC20 _mehToken) ERC721("MehRoyalty", "MR1") {
        mehToken = _mehToken;
    }

    struct Product {
        uint256 totalContracts;  // Total number of contract tokens allowed for this product
        uint256 currentSerial;   // Current serial number (last minted token)
    }

    mapping(uint256 => Product) public products;
    mapping(uint256 => uint256) public deposits;

    function createProduct(
        uint256 _productId,
        uint256 _totalContracts
    ) external onlyOwner {
        products[_productId] = Product({
            totalContracts: _totalContracts,
            currentSerial: 0
        });
    }

    function mint(uint256 _productId, address _to) public nonReentrant {
        require(
            msg.sender == MINTER_ADDRESS,
            "mint can only be called by minter"
        );

        Product storage product = products[_productId];
        require(product.currentSerial < product.totalContracts, "all tokens minted for this product");

        uint256 newSerialNumber = product.currentSerial + 1;
        uint256 tokenId = generateTokenId(_productId, newSerialNumber);

        _mint(_to, tokenId);
        product.currentSerial = newSerialNumber;
    }

    function generateTokenId(uint256 _productId, uint256 _serialNumber) private pure returns (uint256) {
        return _productId * 10000 + _serialNumber;
    }

    function depositMehToken(uint256 tokenId, uint256 amt) public nonReentrant {
        require(_exists(tokenId), "token does not exist");
        mehToken.transferFrom(msg.sender, address(this), amt);
        deposits[tokenId] += amt;
    }

    function extractMehToken(uint256 tokenId, uint256 amt) public nonReentrant {
        require(ownerOf(tokenId) == msg.sender, "caller is not the owner of the token");
        require(deposits[tokenId] >= amt, "insufficient meh");
        require(block.timestamp > 1720054800, "fourth of july");

        deposits[tokenId] = deposits[tokenId] - amt;
        mehToken.transfer(msg.sender, amt);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseTokenURI(string calldata newURI) external onlyOwner {
        baseTokenURI = newURI;
    }

    function updateMinter(address newMinter) external onlyOwner {
        MINTER_ADDRESS = newMinter;
    }

    function baseURI() public view returns (string memory) {
        return baseTokenURI;
    }
}