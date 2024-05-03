// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "hardhat/console.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

interface IRoyalty {
    function depositMehToken(uint256 tokenId, uint256 amt) external payable;
    function mint(uint256 _productId, address _to) external;
}

contract MehVoteV1 is Ownable, ReentrancyGuard {
    IERC20Burnable public immutable mehToken;
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
        IERC20Burnable _mehToken,
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
        bool _limitedRun
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
            prizeMeh: 0,
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
                uint256 totalCost = _numContracts * product.mehContractPrice;
                deposits[msg.sender][_productId] += _numContracts;
                product.mehContractsDeposited += _numContracts;

                require(mehToken.transferFrom(msg.sender, address(this), totalCost), "meh deposit failed");
                found = true;
                break;
            }
        }

        require(found, "product not found");

    }

    function depositMehStore(uint256 _amount) external onlyOwner {
        mehToken.transfer(owner(), _amount);
    }

    function depositPrizeMeh(
        uint256 _gameId,
        uint256 _productId,
        uint256 _amount
    ) external onlyOwner {
        Game storage game = games[_gameId];

        for (uint i = 0; i < game.products.length; i++) {
            if (game.products[i].id == _productId) {
                game.products[i].prizeMeh = _amount;
                mehToken.transferFrom(msg.sender, address(this), _amount);
                break;
            }
        }
    }

    function claim(
        uint256 _gameId,
        uint256 _productId
    ) external nonReentrant {
        Game storage game = games[_gameId];
        Product storage product = game.products[_productId];
        //require(game.end < block.timestamp, "game not ended");
        require(product.id != 0, "product does not exist");

        uint256 contracts = deposits[msg.sender][_productId];
        require(contracts > 0, "no contracts");
        uint256 payout = contracts * product.mehContractPrice;
        if (game.products[_productId].mehStore) {
            payout = product.prizeMeh * (contracts  / product.mehContracts);
            for (uint i = 1; i <= contracts; i++) {
                royalties.mint(_productId, msg.sender);
            }
        }

        deposits[msg.sender][_productId] = 0;
        mehToken.transfer(msg.sender, payout);

    }

    // getters
    function getProductsByGameId(uint256 gameId) public view returns (Product[] memory) {
        return games[gameId].products;
    }
}