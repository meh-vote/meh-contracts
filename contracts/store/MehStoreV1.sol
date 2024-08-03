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
    IERC20 public meh;
    MehStoreNFT public mehStoreNFT;

    mapping(uint256 => Product) public products;
    mapping(uint256 => uint256) public escrow;
    mapping(uint256 => Sale) public sales;

    uint256 public nextProductId;
    uint256 public nextSaleId;
    uint256 public randomFactor = 1;

    event Purchase(
        address indexed buyer,
        uint256 indexed saleId,
        uint256 indexed productId,
        uint256 price, 
        string size
    );

    event RandomMeh(uint256 amount);

    constructor(IERC20 _usdc, address _mehStoreNFTAddress, IERC20 _meh) {
        usdc = _usdc;
        mehStoreNFT = MehStoreNFT(_mehStoreNFTAddress);
        meh = _meh;
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

        uint256 randomAmount = generateRandomAmount();
        if (meh.balanceOf(address(this)) >= randomAmount) {
            require(meh.transfer(msg.sender, randomAmount), "meh token transfer failed");
            emit RandomMeh(randomAmount);
        }
    }

    function generateRandomAmount() internal view returns (uint256) {
        uint256 randomBase = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 199900000 + 100000;
        return randomBase * randomFactor;
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
    function extractMehTokens(uint256 amount) public onlyOwner {
        require(meh.transfer(msg.sender, amount), "meh token transfer failed");
    }

    function setRandomFactor(uint256 _randomFactor) public onlyOwner {
        randomFactor = _randomFactor;
    }

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