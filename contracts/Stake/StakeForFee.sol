// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakeNECOForFee is Ownable {
    using SafeMath for uint;

    IERC20 public neco;
    bool public stakeLock = true;

    // NECO token staked status.
    struct StakedStatus {
        uint stakedAmount; // Total staked amount.
        uint averageStakedTime; // Avarage Staked time for NECO.
    }

    mapping(address => StakedStatus) public stakedStatusInfo;

    constructor(IERC20 _neco) {
        neco = _neco;
    }

    function stakeNECO(uint amount) external {
        require(stakeLock == false, "Stake is locked.");

        // initialize staked status info.
        // if staked amount is 0, set avarage staked time to be current time.
        // The averageStakedTime is a time point not a period.
        if (stakedStatusInfo[msg.sender].stakedAmount.div(1e18) == 0) {
            stakedStatusInfo[msg.sender].averageStakedTime = block.timestamp;
        }

        // get staked time. current time - averageStakedTime
        uint stakedTime = (block.timestamp).sub(stakedStatusInfo[msg.sender].averageStakedTime);

        // algorithm, (oldStakedAmount * StakedTimePeriod) = (oldStakedAmount + amount) * NewStakedTimePeriod
        // NewStakedTimePeriod = (oldStakedAmount * StakedTimePeriod) / (oldStakedAmount + amount)
        uint newStakedTimePeriod = stakedTime.mul(amount.div(1e18)).div(amount.div(1e18).add(stakedStatusInfo[msg.sender].stakedAmount.div(1e18)));

        // new staked time point = now - newStakedTimePeriod
        uint newStakedTime = block.timestamp.sub(newStakedTimePeriod);

        neco.transferFrom(msg.sender, address(this), amount);

        stakedStatusInfo[msg.sender].stakedAmount = stakedStatusInfo[msg.sender].stakedAmount.add(amount);
        stakedStatusInfo[msg.sender].averageStakedTime = newStakedTime;
    }

    // Withdraw NECO token.
    function withdrawNECO(uint amount) external {
        require(stakedStatusInfo[msg.sender].stakedAmount >= amount, "No enough staked balance.");
        neco.transfer(msg.sender, amount);
        stakedStatusInfo[msg.sender].stakedAmount = stakedStatusInfo[msg.sender].stakedAmount.sub(amount);
    }

    function unlockStake() external onlyOwner {
        require(stakeLock == true, "stake lock is already false.");
        stakeLock = false;
    }

    function lockStake() external onlyOwner {
        require(stakeLock == false, "Stake lock is already true.");
        stakeLock = true;
    }

    function getStakedNECOAmount(address account) view public returns(uint) {
        return stakedStatusInfo[account].stakedAmount;
    }

    function getStakedTimePeriod(address account) view public returns(uint) {
        return block.timestamp.sub(stakedStatusInfo[account].averageStakedTime);
    }
}