// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../NFT/INecoNFT.sol";


contract StakeForNFT is Ownable {
    using SafeMath for uint;

    IERC20 stakeToken;
    INecoNFT necoNFT;

    uint public id;
    uint public tokenRequiredAmount;
    uint public earnedNFTId;
    uint public farmingPeriod;
    bool public lock;

    mapping(address => uint) stakedAmountForAccount;
    mapping(address => uint) unlockTimeForAccount;
    mapping(address => bool) stakedStatusForAccount;

    constructor(IERC20 _stakeToken, INecoNFT _necoNFT) {
        stakeToken = _stakeToken;
        necoNFT = _necoNFT;
        lock = true;
    }

    function initInfo(
        uint _id,
        uint _tokenRequiredAmount,
        uint _earnedNFTId,
        uint _farmingPeriod
    ) external onlyOwner {
        id = _id;
        tokenRequiredAmount = _tokenRequiredAmount;
        earnedNFTId = _earnedNFTId;
        farmingPeriod = _farmingPeriod;
    }

    function unlockStaking() external onlyOwner {
        require(necoNFT.minters(address(this)), "NFT farming pool is not a minter");
        require(lock == false, "Farming pool is already opened.");
        lock = false;
    }

    function lockStaking() external onlyOwner {
        require(lock == true, "Farming pool is already closed.");
        lock = true;
    }

    function stake() external {
        require(lock == false, "Staking is locked.");
        require(stakeToken.balanceOf(msg.sender) >= tokenRequiredAmount, "Insufficient Balance.");
        require(!stakedStatusForAccount[msg.sender], "You are staking.");
        stakeToken.transferFrom(msg.sender, address(this), tokenRequiredAmount);
        stakedAmountForAccount[msg.sender] = stakedAmountForAccount[msg.sender].add(tokenRequiredAmount);
        stakedStatusForAccount[msg.sender] = true;
        unlockTimeForAccount[msg.sender] = block.timestamp.add(farmingPeriod);
    }

    function withdraw() external {
        require(stakedStatusForAccount[msg.sender], "You are not staking.");
        require(unlockTimeForAccount[msg.sender] >= block.timestamp, "Token is still locked.");
        stakeToken.transfer(msg.sender, stakedAmountForAccount[msg.sender]);
        stakedStatusForAccount[msg.sender] = false;
        necoNFT.mint(earnedNFTId, msg.sender, 1, "NFT Farming Reward.");
    }
}