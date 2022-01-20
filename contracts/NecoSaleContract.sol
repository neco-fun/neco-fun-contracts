// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NecoSaleContract is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _addressSet;
    mapping (address=>bool) public whitelist;

    address public devAddress;
    // NECO Token Price; 1 NECO for 3 busd
    uint public necoTokenPrice = 3;
    // NECO Token Amount in this contract.
    uint public necoTokenTotalAmount = 0;
    uint public necoTokenTotalSoldAmount = 0;
    // Max limitation for every account; 1500U for everyone
    uint public buyLimit = 1500 * 1e18;

    // Claim Map
    struct ClaimTimeStruct {
        uint startTime;
        uint endTime;
    }
    mapping (uint => ClaimTimeStruct) public claimTimes;

    // How much token user has bought.
    mapping (address => uint) public hasBoughtPerAccount;
    // How much token user can claim for per account.
    mapping (address => uint) public necoTokenAmountPerAccount;

    mapping (address => mapping (uint => uint)) public userClaimRoadMap;

    /**
        Contract Switch
     */
    bool public saleStarted = false;
    bool public fcfsEnabled = false;
    bool public claimEnabled = false;

    IERC20 public necoToken;
    IERC20 public busd;

    event BuyNecoSuccess(address indexed account, uint usdAmount, uint necoAmount);
    event ClaimSuccess(address indexed account, uint necoAmount);

    // for that time, we may need to add whitelist 1 by 1, or we may init them at one time.
    constructor(address account, IERC20 _necoToken, IERC20 _busd) {
        devAddress = account;
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
        saleStarted = true;
    }

    function stopSale() external onlyOwner {
        saleStarted = false;
    }

    // this contract will be deployed on Polygon, So we should deposit NECO tokens
    // into this contract and setup its status.
    function depositNecoToken(uint amount) external onlyOwner {
        necoToken.transferFrom(msg.sender, address(this), amount);
        necoTokenTotalAmount = necoToken.balanceOf(address(this));
    }

    // enable claim. will be generate 9 time interval.
    // so we can get the index for claiming according to current time.
    function enableClaim() external onlyOwner {
        claimEnabled = true;

        uint claimPeriod = 30 days;
        uint claimStartTime = block.timestamp;
        uint claimEndTime = block.timestamp + claimPeriod;

        for (uint i = 0; i < 5; i ++) {
            claimTimes[i].startTime = claimStartTime;
            claimTimes[i].endTime = claimEndTime;

            claimStartTime = claimEndTime;
            claimEndTime = claimEndTime + claimPeriod;
        }
    }

    // get index of cliaming accroding to current time.
    function getCurrentIndexOfClaim() view public returns(uint) {
        uint currentTime = block.timestamp;
        for (uint i = 0; i < 5; i ++) {
            if (currentTime >= claimTimes[i].startTime &&
            currentTime < claimTimes[i].endTime) {
                return i;
            }
        }
        return 5;
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
        // update status
        hasBoughtPerAccount[msg.sender] = hasBoughtPerAccount[msg.sender].add(busdAmountRequired);
        necoTokenAmountPerAccount[msg.sender] = necoTokenAmountPerAccount[msg.sender].add(necoAmount);

        buildClaimRoadmap(msg.sender);
        necoTokenTotalAmount = necoTokenTotalAmount.sub(necoAmount);
        necoTokenTotalSoldAmount = necoTokenTotalSoldAmount.add(necoAmount);
        emit BuyNecoSuccess(msg.sender, busdAmountRequired, necoAmount);
        return true;
    }

    // claim token. then update user's claim map.
    function claimToken() external returns(bool) {
        require(claimEnabled, "Claim has not been started.");
        require(necoTokenAmountPerAccount[msg.sender] > 0, "You have no NECO token.");

        uint claimableAmount = necoTokenClaimableAmount(msg.sender);
        require(claimableAmount > 0, "Your claimable NECO is 0");
        if (necoTokenAmountPerAccount[msg.sender] < claimableAmount) {
            necoToken.transfer(msg.sender, necoTokenAmountPerAccount[msg.sender]);
            necoTokenAmountPerAccount[msg.sender] = 0;

            return true;
        }

        necoToken.transfer(msg.sender, claimableAmount);
        necoTokenAmountPerAccount[msg.sender] = necoTokenAmountPerAccount[msg.sender]
            .sub(claimableAmount);

        uint currentIndex = getCurrentIndexOfClaim();
        for (uint i = 0; i <= currentIndex; i++) {
            userClaimRoadMap[msg.sender][i] = 0;
        }

        emit ClaimSuccess(msg.sender, claimableAmount);
        return true;
    }

    // build a claim roadmap, so that we can know how many tokens users can get accroding to current index.
    function buildClaimRoadmap(address account) private {
        uint necoClaimablePerMonth = necoTokenAmountPerAccount[account].mul(2).div(10);
        for (uint i = 0; i < 5; i ++) {
            userClaimRoadMap[account][i] = necoClaimablePerMonth;
        }
    }

    // get amount user can claim for current claim index.
    function necoTokenClaimableAmount(address account) view public returns(uint) {
        uint currentIndex = getCurrentIndexOfClaim();
        uint claimableAmount = 0;
        for (uint i = 0; i <= currentIndex; i++) {
            uint claimableAmountOfThisTime = userClaimRoadMap[account][i];
            claimableAmount = claimableAmount.add(claimableAmountOfThisTime);
        }
        return claimableAmount;
    }

    function emergencyWithdraw(uint amount) external onlyOwner {
        necoToken.transfer(owner(), amount);
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