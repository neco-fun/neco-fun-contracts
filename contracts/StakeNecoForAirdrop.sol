     // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakeNECOForNFISH is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;

    IERC20 public neco;
    IERC20 public nfish;

    bool public hasStarted = false;
    uint public minimumStake = 500 * 1e18;
    uint public unlockTime;
    mapping(address => bool) public stakeLock;
    mapping(address=>uint) public stakedAmounts;
    mapping(address => uint) public rewards;
    uint public totalStakedAmount;
    uint public totalAirdropAmount = 1000000 * 1e18;

    constructor(IERC20 _neco, IERC20 _nfish) {
        neco = _neco;
        nfish = _nfish;
    }

    function initPool() external onlyOwner {
        nfish.safeTransferFrom(msg.sender, address(this), totalAirdropAmount);
    }

    function withdrawNfish() external onlyOwner {
        nfish.transfer(owner(), nfishBalance());
    }

    function nfishBalance() view public returns(uint) {
        return nfish.balanceOf(address(this));
    }

    function isLocked() view public returns(bool) {
        return block.timestamp >= unlockTime;
    }

    function startStaking() external onlyOwner {
        require(hasStarted == false, "Staking has been started.");
        hasStarted = true;
    }

    function stopStaking() external onlyOwner {
        require(hasStarted == true, "Staking has been stopped.");
        hasStarted = false;
    }

    function stake(uint amount) external {
        require(hasStarted, "Stake has not started.");
        totalStakedAmount = totalStakedAmount.add(amount);
        stakedAmounts[msg.sender] = stakedAmounts[msg.sender].add(amount);
        neco.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external {
        require(block.timestamp >= unlockTime, "Please wait to unlock time.");
        uint stakedAmount = stakedAmounts[msg.sender];
        neco.safeTransfer(msg.sender, stakedAmount);
    }

    function claim() external {
        require(block.timestamp >= unlockTime, "Please wait to unlock time.");
        uint reward = rewardOfAccount(msg.sender);
        nfish.safeTransfer(msg.sender, reward);
    }

    function rewardOfAccount(address account) view public returns(uint) {
        uint myStakedAmount = stakedAmounts[account];
        uint myAirdropReward = myStakedAmount.mul(totalAirdropAmount).div(totalStakedAmount);
        return myAirdropReward;
    }
}