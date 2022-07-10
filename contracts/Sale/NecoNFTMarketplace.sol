// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


contract NecoMarketplace is Ownable, ERC1155Holder {
    using Address for address;
    using SafeMath for uint;
    using Counters for Counters.Counter;
    using EnumerableSet for EnumerableSet.UintSet;

    Counters.Counter private _itemIdCounter;
    Counters.Counter private _ItemSoldCounter;

    IERC20 public nfishToken; //NFISH token
    IERC1155 public necoNFT; // NECO NFT
    address public devAddress; // Fee charger
    bool public locked = false;

    // Percent of trading fee; default is 5%
    uint public fee = 5;

    struct Item {
        uint id;
        address seller;
        address buyer;
        uint nftId;
        uint amount;
        uint price;
        uint onListTime;
        bool isOnList;
        bool isSold;
        uint soldTime;
    }
    // Get item by id
    mapping (uint => Item) public idToItem;
    // Query items posted by user
    mapping (address=>EnumerableSet.UintSet) private _sellerToPublishedId;
    // Query items sold by user
    mapping (address=>EnumerableSet.UintSet) private _sellerToSoldId;
    // Query items bought by user
    mapping (address=>EnumerableSet.UintSet) private _buyerToItemId;

    event PublishNewItem(address indexed account, uint ItemId, uint nftId, uint amount, uint price);
    event RevertOnListItem(address indexed account, uint ItemId, uint nftId);
    event ChangePrice(address indexed account, uint ItemId, uint nftId, uint oldPrice, uint newPrice);
    event BuyItem(address indexed buyer, address indexed seller, uint ItemId, uint nftId, uint cost, uint fee);

    constructor(IERC20 _nfishToken, IERC1155 _necoNFT, address _devAddress) {
        nfishToken = _nfishToken;
        necoNFT = _necoNFT;
        devAddress = _devAddress;
    }

    function publishNewItem(uint nftId, uint amount, uint price) external unlocked {
        uint id = _itemIdCounter.current();
        Item storage item = idToItem[id];
        item.id = id;
        item.seller = msg.sender;
        item.nftId = nftId;
        item.amount = amount;
        item.price = price;
        item.onListTime = block.timestamp;
        item.isSold = false;
        item.isOnList = true;
        item.soldTime = 0;
        _itemIdCounter.increment();
        necoNFT.safeTransferFrom(msg.sender, address(this), nftId, amount, 'Sell NFT');

        EnumerableSet.UintSet storage publishedIds = _sellerToPublishedId[msg.sender];
        publishedIds.add(id);

        emit PublishNewItem(msg.sender, id, nftId, amount, price);
    }

    function revertOnListItem(uint id) external {
        Item storage item = idToItem[id];
        require(item.seller == msg.sender, "Restrict for seller");
        require(item.isSold == false, "Item has been sold out!");
        require(item.isOnList == true, "Item is not on list");
        item.isOnList = false;
        necoNFT.safeTransferFrom(address(this), msg.sender, item.nftId, item.amount, "Rever Item on list");
        EnumerableSet.UintSet storage publishedIds = _sellerToPublishedId[msg.sender];
        publishedIds.remove(id);

        emit RevertOnListItem(msg.sender, item.id, item.nftId);
    }

    function changePrice(uint id, uint newPrice) external  {
        Item storage item = idToItem[id];
        require(item.seller == msg.sender, "Restrict for seller");
        require(item.isSold == false, "Item has been sold out!");
        require(item.isOnList == true, "Item is not on list");
        uint oldPrice = item.price;
        item.price = newPrice;

        emit ChangePrice(msg.sender, item.id, item.nftId, oldPrice, newPrice);
    }

    function buyItem(uint id) external {
        Item storage item = idToItem[id];
        require(!item.isSold, "Item is sold out!");
        require(msg.sender != item.seller, "You are seller");
        uint nfishAmountRequired = item.amount.mul(item.amount);
        uint tradingFee = nfishAmountRequired.mul(fee).div(100);
        uint toSeller = nfishAmountRequired.sub(tradingFee);
        nfishToken.transferFrom(msg.sender, item.seller, toSeller);
        nfishToken.transferFrom(msg.sender, devAddress, tradingFee);
        necoNFT.safeTransferFrom(address(this), msg.sender, item.nftId, item.amount, 'Buy NFT');
        item.buyer = msg.sender;
        item.isSold = true;
        item.isOnList = false;
        item.soldTime = block.timestamp;
        EnumerableSet.UintSet storage soldIds = _sellerToSoldId[item.seller];
        soldIds.add(id);

        EnumerableSet.UintSet storage publishedIds = _sellerToPublishedId[item.seller];
        publishedIds.remove(id);

        EnumerableSet.UintSet storage boughtIds = _buyerToItemId[msg.sender];
        boughtIds.add(id);

        _ItemSoldCounter.increment();

        emit BuyItem(msg.sender, item.seller, item.id, item.nftId, toSeller, tradingFee);
    }

    function getItemTotalAmount() external view returns(uint) {
        return _itemIdCounter.current();
    }

    function getItem(uint id) external view returns(Item memory) {
        return idToItem[id];
    }

    function getPublishIdAmountOfUser(address account) view public returns(uint) {
        return _sellerToPublishedId[account].length();
    }

    function getPublishId(address account, uint index) view public returns(uint) {
        return _sellerToPublishedId[account].at(index);
    }

    function getSoldIdAmountOfUser(address account) view public returns(uint) {
        return _sellerToSoldId[account].length();
    }

    function getSoldId(address account, uint index) view public returns(uint) {
        return _sellerToSoldId[account].at(index);
    }

    function getBoughtIdAmountOfUser(address account) view public returns(uint) {
        return _buyerToItemId[account].length();
    }

    function getBoughtId(address account, uint index) view public returns(uint) {
        return _buyerToItemId[account].at(index);
    }

    function changeTradingFee(uint newFee) external onlyOwner {
        fee = newFee;
    }

    function changeDevAddress(address account) external onlyOwner {
        require(account != address(0), "New account cannot be 0!");
        devAddress = account;
    }

    function lockMarketplace() external onlyOwner {
        locked = true;
    }

    function unlockMarketplace() external onlyOwner {
        locked = false;
    }

    modifier unlocked() {
        require(locked == false, "Marketplace is locked!");
        _;
    }
}