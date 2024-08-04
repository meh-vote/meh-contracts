// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MehStoreNFT is ERC721, Ownable {
    struct NFTDetails {
        uint256 productId;
        uint256 price;
        string deliveryAddress;
    }

    mapping(uint256 => NFTDetails) private nftDetails;
    mapping(uint256 => uint256) public productToToken;
    uint256 public nextTokenId;
    address public mehStoreV1;

    constructor() ERC721("MehStoreNFT", "MS") {}

    // public functions
    function getPrice(uint256 tokenId) public view returns (uint256) {
        return nftDetails[tokenId].price;
    }

    function enterDeliveryAddress(uint256 tokenId, string memory deliveryAddress) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        nftDetails[tokenId].deliveryAddress = deliveryAddress;
        _transfer(msg.sender, owner(), tokenId);
    }

    function getTokenIdByProductId(uint256 productId) public view returns (uint256) {
        return productToToken[productId];
    }

    // meh.store functions
    function mint(address to, uint256 productId, uint256 price) external onlyMehStoreV1 {
        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId);
        nftDetails[tokenId] = NFTDetails(productId, price, "");
        productToToken[productId] = tokenId;
    }

    function burn(uint256 tokenId) external onlyMehStoreV1 {
        delete productToToken[nftDetails[tokenId].productId];
        _burn(tokenId);
        delete nftDetails[tokenId];
    }


    // administrative
    function setMehStoreV1(address _mehStoreV1) public onlyOwner {
        mehStoreV1 = _mehStoreV1;
    }

    function getNFTDetails(uint256 tokenId) public view onlyOwner returns (NFTDetails memory) {
        return nftDetails[tokenId];
    }

    // modifiers
    modifier onlyMehStoreV1() {
        require(msg.sender == mehStoreV1, "Only MehStoreV1 can call this function");
        _;
    }
}