// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MehStoreNFT.sol";

contract MehStoreV1 is Ownable {
    enum Category {
        Shirt,
        Hoodie,
        Hat,
        Deck,
        Hair,
        Jacket,
        Pants,
        CyberMask,
        Digital
    }

    struct Product {
        uint256 price;
        string title;
        string description;
        string mediaURL;
        Category category;
        bool isShipped;
    }

    IERC20 public usdc;
    mapping(uint256 => Product) public products;
    mapping(uint256 => uint256) public escrow;

    uint256 public nextProductId;
    MehStoreNFT public mehStoreNFT;

    constructor(IERC20 _usdc, address _mehStoreNFTAddress) {
        usdc = _usdc;
        mehStoreNFT = MehStoreNFT(_mehStoreNFTAddress);
    }

    function addProduct(
        uint256 price,
        string memory title,
        string memory description,
        string memory mediaURL,
        Category category
    ) public onlyOwner {
        products[nextProductId] = Product(price, title, description, mediaURL, category, false);
        nextProductId++;
    }

    function purchaseProduct(uint256 productId) public {
        Product storage product = products[productId];
        require(usdc.transferFrom(msg.sender, address(this), product.price), "Payment failed");
        escrow[productId] += product.price;
        mehStoreNFT.mint(msg.sender, productId, product.price);
    }

    function refund(uint256 productId) public {
        uint256 tokenId = mehStoreNFT.getTokenIdByProductId(productId);
        require(mehStoreNFT.ownerOf(tokenId) == address(this), "NFT not deposited");
        uint256 price = mehStoreNFT.getPrice(tokenId);
        usdc.transfer(msg.sender, price);
        escrow[productId] -= price;
        mehStoreNFT.burn(tokenId);
    }

    function shipProduct(uint256 productId) public onlyOwner {
        Product storage product = products[productId];
        require(!product.isShipped, "Already shipped");
        product.isShipped = true;
        uint256 price = escrow[productId];
        escrow[productId] = 0;
        //TODO distribute to royalty owners
        usdc.transfer(owner(), price);
    }
}