// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NewNecoSaleContract is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _addressSet;
    mapping (address=>bool) public whitelist;

    address public devAddress;
    // NECO Token Price; 1 NECO for 4 busd
    uint public necoTokenPrice = 4;
    // Max limitation for every account; 2000U for everyone
    uint public buyLimit = 2000 * 1e18;
    // NECO Token Amount in this contract. for 100 whitelists
    uint public necoTokenTotalAmount = 100000 * 1e18;
    // the amount of slod neco.
    uint public necoTokenTotalSoldAmount = 0;
    // How much BUSD users has spent.
    mapping (address => uint) public hasBoughtPerAccount;

    bool public initialized = false;
    /**
        Contract Switch
     */
    bool public saleStarted = false;
    bool public fcfsEnabled = false;
    bool public claimEnabled = false;

    IERC20 public necoToken;
    IERC20 public busd;

    event BuyNecoSuccess(address indexed account, uint usdAmount, uint necoAmount);

    // for that time, we may need to add whitelist 1 by 1, or we may init them at one time.
    constructor(IERC20 _necoToken, IERC20 _busd) {
        devAddress = owner();
        necoToken = _necoToken;
        busd = _busd;
        initWhitelist();
    }

    // add account into whitelist.
    function addToWhitelist(address account) external onlyOwner {
        require(whitelist[account] == false && account != address(0), "This account is already in whitelist.");
        whitelist[account] = true;
        _addressSet.add(account);
    }

    // remove account from whitelist.
    function removeFromWhitelist(address account) external onlyOwner {
        require(whitelist[account] && account != address(0), "This account is not in whitelist.");
        whitelist[account] = false;
        _addressSet.remove(account);
    }

    function setDevAddress(address account) external onlyOwner {
        require(account != address(this), "account can not be 0!");
        devAddress = account;
    }

    // start sale
    function startSale() external onlyOwner {
        require(initialized, "Need to call initData firstly.");
        saleStarted = true;
    }

    function stopSale() external onlyOwner {
        saleStarted = false;
    }

    // this contract will be deployed on Polygon, So we should deposit NECO tokens
    // into this contract and setup its status.
    function initData() external onlyOwner {
        necoToken.transferFrom(msg.sender, address(this), necoTokenTotalAmount);
        initialized = true;
    }

    // set neco token again.
    function setNecoTokenPrice(uint newPrice) external onlyOwner {
        necoTokenPrice = newPrice;
    }

    // set buy limit again
    function setBuyLimit(uint newLimit) external onlyOwner {
        buyLimit = newLimit;
    }

    // open buying for everyone
    function changeToFCFS() external onlyOwner {
        fcfsEnabled = true;
    }

    // buy NECO token.
    function buyNecoToken(uint necoAmount) external saleHasStarted needHaveRemaining returns(bool) {
        if (!fcfsEnabled) {
            require(whitelist[msg.sender], "You are not in whitelist, you can wait for FCFS");
        }

        require(necoAmount >= 1e18, "at least 1 NECO");
        uint busdAmountRequired = necoAmount.mul(necoTokenPrice);
        require(hasBoughtPerAccount[msg.sender].add(busdAmountRequired) <= buyLimit, "Oh no! You want to buy too much");
        require(necoAmount <= necoTokenTotalAmount, "Oh no! there is no enough token remaining.");
        busd.safeTransferFrom(msg.sender, devAddress, busdAmountRequired);
        necoToken.safeTransfer(msg.sender, necoAmount);

        // update status
        hasBoughtPerAccount[msg.sender] = hasBoughtPerAccount[msg.sender].add(busdAmountRequired);

        necoTokenTotalAmount = necoTokenTotalAmount.sub(necoAmount);
        necoTokenTotalSoldAmount = necoTokenTotalSoldAmount.add(necoAmount);
        emit BuyNecoSuccess(msg.sender, busdAmountRequired, necoAmount);
        return true;
    }

    function withdrawRemaining() external onlyOwner {
        necoToken.transfer(owner(), necoTokenTotalAmount);
    }

    function initWhitelist() internal {
        whitelist[0x3c5de42f02DebBaA235f7a28E4B992362FfeE0B6] = true;
        _addressSet.add(0x3c5de42f02DebBaA235f7a28E4B992362FfeE0B6);
    }

    function getWhitelistAccountAmount() view external returns(uint) {
        return _addressSet.length();
    }

    function getWhitelistAccountById(uint index) view external returns(address) {
        return _addressSet.at(index);
    }

    modifier needHaveRemaining() {
        require(necoTokenTotalAmount > 0, "Oh you are so late.");
        _;
    }

    modifier saleHasStarted() {
        require(saleStarted, "sale has not been started.");
        _;
    }
}