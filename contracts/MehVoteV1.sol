// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


interface IRoyalty {
    function depositMehToken(uint256 tokenId, uint256 amt) external payable;
    function mint(uint256 _productId, address _to) external;
}

contract MehVoteV1 is Ownable, ReentrancyGuard {
    IERC20 public immutable mehToken;
    IRoyalty public immutable royalties;

    using Counters for Counters.Counter;
    Counters.Counter private gameIdCounter;
    Counters.Counter private productIdCounter;

    struct Game {
        uint256 id;
        uint256 begin;
        uint256 end;
        Product[] products;
        uint256 numProducts;
    }

    struct Product {
        uint256 id;
        string name;
        uint256 mehContractsDeposited; // meh contracts deposited
        uint256 mehContracts; // meh contracts available
        uint256 mehContractPrice; // price per contract
        uint256 prizeMeh; // prize in meh
        bool mehStore; // event sent to list on meh.store
        uint256 begin;
        uint256 end;
        uint256 totalContracts;
        bool limitedRun;
    }

    event MehStore (
        uint256 productId,
        string productName,
        string allocatorMerkleRoot,
        uint256 totalContracts
    );

    mapping(uint256 => Game) public games;
    mapping(address => mapping(uint256 => uint256)) public deposits;

    constructor(
        IERC20 _mehToken,
        IRoyalty _royalties
    ) {
        mehToken = _mehToken;
        royalties = _royalties;
        gameIdCounter.increment();
        productIdCounter.increment();
    }

    function createGame(
        uint256 _begin,
        uint256 _end
    ) external onlyOwner {
        uint256 gameId = gameIdCounter.current();
        Game storage game = games[gameId];
        game.id = gameId;
        game.begin = _begin;
        game.end = _end;

        gameIdCounter.increment();
    }

    function addProductToGame(
        uint256 _gameId,
        string memory _name,
        uint256 _mehContracts,
        uint256 _mehContractPrice,
        uint256 _begin,
        uint256 _end,
        uint256 _totalContracts,
        bool _limitedRun,
        uint256 _prizeMeh
    ) external onlyOwner {
        Game storage game = games[_gameId];
        require(game.id != 0, "game does not exist");

        uint256 productId = productIdCounter.current();
        Product memory newProduct = Product({
            id: productId,
            name: _name,
            mehContractsDeposited: 0,
            mehContracts: _mehContracts,
            mehContractPrice: _mehContractPrice,
            prizeMeh: _prizeMeh,
            mehStore: false,
            begin: _begin,
            end: _end,
            totalContracts: _totalContracts,
            limitedRun : _limitedRun
        });
        game.products.push(newProduct);
        game.numProducts++;
        productIdCounter.increment();
    }

    function depositMeh(
        uint256 _gameId,
        uint256 _productId,
        uint256 _numContracts
    ) public nonReentrant {
        Game storage game = games[_gameId];
        Product storage product;
        bool found = false;

        for (uint256 i = 0; i < game.products.length; i++) {
            if (game.products[i].id == _productId) {
                product = game.products[i];
                require(!product.mehStore, "product already listed on meh.store");
                require(product.mehContractsDeposited + _numContracts <= product.mehContracts, "not enough contracts available");
                require(block.timestamp > product.begin, "product not open for deposit");
                require(block.timestamp < product.end, "product not open for deposit");
                uint256 totalCost = _numContracts * product.mehContractPrice;
                deposits[msg.sender][_productId] += _numContracts;
                product.mehContractsDeposited += _numContracts;

                require(mehToken.transferFrom(msg.sender, address(this), totalCost), "meh deposit failed");
                found = true;
                if(product.mehContractsDeposited == product.mehContracts) {
                    product.mehStore = true;
                    product.end = block.timestamp;

                    emit MehStore(
                        product.id,
                        product.name,
                        'def-123',
                        product.totalContracts
                    );
                }
                break;
            }
        }

        require(found, "product not found");

    }

    function depositMehStore(uint256 _amount) external onlyOwner {
        mehToken.transfer(owner(), _amount);
    }

    function claim(
        uint256 _gameId,
        uint256 _productId
    ) external nonReentrant {
        Game storage game = games[_gameId];

        for (uint i = 0; i < game.products.length; i++) {
            if (game.products[i].id == _productId) {
                Product storage product = game.products[i];
                require(product.end < block.timestamp, "product active");
                require(product.mehStore, "product not in store");
                uint256 contracts = deposits[msg.sender][_productId];
                require(contracts > 0, "no contracts");

                if (product.mehStore) {
                    for (uint j = 1; j <= contracts; j++) {
                        royalties.mint(_productId, msg.sender);
                    }
                }
                deposits[msg.sender][_productId] = 0;
                return;
            }
        }

        revert("invalid product");

    }

    // getters
    function getProductsByGameId(uint256 gameId) public view returns (Product[] memory) {
        return games[gameId].products;
    }
}