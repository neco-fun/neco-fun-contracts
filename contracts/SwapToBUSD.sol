// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SwapNecoToBUSD is Ownable {
    using SafeMath for uint;

    IERC20 public neco;
    IERC20 public busd;
    uint public necoPrice = 4;

    bool public swapLock = true;

    constructor(IERC20 _neco, IERC20 _busd) {
        neco = _neco;
        busd = _busd;
    }

    function swap() public {
        require(!swapLock, "swap function is locked.");

        uint necoAmount = neco.balanceOf(msg.sender);
        require(necoAmount > 0, "Not enough NECO token.");
        neco.transferFrom(msg.sender, address(this), necoAmount);
        uint busdAmount = necoAmount.mul(necoPrice);
        busd.transfer(msg.sender, busdAmount);
    }

    function withdrawBUSD() external onlyOwner {
        uint busdAmount = busd.balanceOf(address(this));
        busd.transfer(owner(), busdAmount);
    }

    function unlockSwap() external onlyOwner {
        require(swapLock == true, "swap lock has been unlocked.");
        swapLock = false;
    }

    function lockSwap() external onlyOwner {
        require(swapLock == false, "swap lock is locked.");
        swapLock = true;
    }

    function busdBalance() view public returns(uint) {
        return busd.balanceOf(address(this));
    }
}