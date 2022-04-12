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
    bool public hasStarted = false;
    uint public minimumStake = 500 * 1e18;
    uint public unlockTime;
    mapping(address => bool) public stakeLock;
    mapping(address=>uint) public stakedAmounts;
    uint public totalStakedAmount;

    constructor(IERC20 _neco) {
        neco = _neco;
    }

    function stake(uint amount) external {
        require(hasStarted, "Stake has not started.");
        totalStakedAmount = totalStakedAmount.add(amount);
        stakedAmounts[msg.sender] = stakedAmounts[msg.sender].add(amount);
        neco.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw() external {
        require(block.timestamp >= unlockTime, "Please wait for unlock time.");
        uint stakedAmount = stakedAmounts[msg.sender];

    }
}