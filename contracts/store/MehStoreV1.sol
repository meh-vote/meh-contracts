// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MehStoreNFT.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MehStoreV1 is Ownable, ReentrancyGuard {
    
    struct Product {
        uint256 price;
        string title;
        string mediaURL;
        bool isShipped;
        bool isActive;
        string[] sizes;
    }

    struct Sale {
        address buyer;
        uint256 productId;
        uint256 price;
        string size;
    }

    IERC20 public usdc;
    mapping(uint256 => Product) public products;
    mapping(uint256 => uint256) public escrow;
    mapping(uint256 => Sale) public sales;

    uint256 public nextProductId;
    uint256 public nextSaleId;
    MehStoreNFT public mehStoreNFT;

    event Purchase(
        address indexed buyer,
        uint256 indexed saleId,
        uint256 indexed productId,
        uint256 price, 
        string size
    );

    constructor(IERC20 _usdc, address _mehStoreNFTAddress) {
        usdc = _usdc;
        mehStoreNFT = MehStoreNFT(_mehStoreNFTAddress);
    }

    function purchaseProduct(
        uint256 productId, 
        string memory size, 
        bool applyDiscount
    ) external nonReentrant {
        Product storage product = products[productId];
        require(product.isActive, "Product is not active");

        uint256 price = product.price;
        if (applyDiscount) {
            price = (price * 75) / 100; // Apply 25% discount
        }

        require(usdc.transferFrom(msg.sender, address(this), price), "Payment failed");
        escrow[productId] += price;
        mehStoreNFT.mint(msg.sender, productId, price);

        uint256 saleId = nextSaleId;
        sales[saleId] = Sale(msg.sender, productId, price, size);
        nextSaleId++;

        emit Purchase(msg.sender, saleId, productId, price, size);
    }

    function refund(uint256 productId) external nonReentrant {
        Product storage product = products[productId];
        require(!product.isShipped, "Products in shipping cannot be refunded");

        uint256 tokenId = mehStoreNFT.getTokenIdByProductId(productId);
        require(mehStoreNFT.ownerOf(tokenId) == msg.sender, "NFT not deposited");
        uint256 price = mehStoreNFT.getPrice(tokenId);
        require(usdc.transfer(msg.sender, price), "Refund failed");
        escrow[productId] -= price;
        mehStoreNFT.burn(tokenId);
    }

    /// administrative functions
    function addProduct(
        uint256 price,
        string memory title,
        string memory mediaURL
    ) public onlyOwner {
        products[nextProductId] = Product(
            price, 
            title, 
            mediaURL,
            false, 
            true,
            new string[](0)
        );
        nextProductId++;
    }

    function updateProduct(
        uint256 productId, 
        uint256 newPrice, 
        string memory newTitle, 
        string memory newMediaURL
    ) public onlyOwner {
        Product storage product = products[productId];
        product.price = newPrice;
        product.title = newTitle;
        product.mediaURL = newMediaURL;
    }

    function deactivateProduct(
        uint256 productId
    ) public onlyOwner {
        products[productId].isActive = false;
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

    function addProductSize(uint256 productId, string memory newSize) public onlyOwner {
        Product storage product = products[productId];
        product.sizes.push(newSize);
    }

    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        uint256 contractBalance = usdc.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient USDC balance in contract");

        usdc.transfer(owner(), amount);
    }
}