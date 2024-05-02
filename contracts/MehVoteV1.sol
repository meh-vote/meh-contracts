// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IERC20Burnable is IERC20 {
    function burn(uint256 amount) external;
}

contract MehVoteV1 is Ownable, ReentrancyGuard {
    IERC20Burnable public immutable mehToken;

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

    constructor(IERC20Burnable _mehToken) {
        mehToken = _mehToken;
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
    ) external nonReentrant {
        Game storage game = games[_gameId];
        Product storage product = game.products[_productId];

        require(product.id != 0, "product does not exist");
        require(!product.mehStore, "product already in meh.store");
        require(
            product.mehContractsDeposited + _numContracts > product.mehContracts,
            "sellout"
        );

        uint256 amt = _numContracts * product.mehContractPrice;
        mehToken.transferFrom(msg.sender, address(this), amt);
        deposits[msg.sender][_productId] += _numContracts;
        product.mehContractsDeposited += _numContracts;

        if (product.mehContractsDeposited + _numContracts >= product.mehContracts) {
            product.mehStore = true;
            string memory merkleRoot = "def-001";

            emit MehStore(
                _productId,
                product.name,
                merkleRoot,
                product.totalContracts
            );
        }
        product.mehContractsDeposited += _numContracts;
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
        Product storage product = game.products[_productId];

        require(product.id != 0, "product does not exist");
        product.prizeMeh += _amount;

        mehToken.transferFrom(msg.sender, address(this), _amount);
    }

    function burnLoserPrizeMeh(
        uint256 _gameId,
        uint256 _productId
    ) external onlyOwner {
        Game storage game = games[_gameId];
        Product storage product = game.products[_productId];
        require(!product.mehStore, "product in store");

        if (product.prizeMeh > 0) {
            mehToken.burn(product.prizeMeh);
        }
    }

    function claim(
        uint256 _gameId,
        uint256 _productId
    ) external nonReentrant {
        Game storage game = games[_gameId];
        require(game.end < block.timestamp, "game not ended");
        require(game.products[_productId].mehStore, "product not in store");

        uint256 contracts = deposits[msg.sender][_productId];
        require(contracts > 0, "no contracts");

        Product storage product = game.products[_productId];
        uint256 payout = product.prizeMeh * (contracts  / product.mehContracts);
        deposits[msg.sender][_productId] = 0;
        mehToken.transfer(msg.sender, payout);

        //todo handle losers
        //todo mint contracts
    }

    // getters
    function getProductsByGameId(uint256 gameId) public view returns (Product[] memory) {
        return games[gameId].products;
    }
}