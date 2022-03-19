// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INecoToken.sol";

contract SwapNecoToBUSD is Ownable {
    using SafeMath for uint;

    IERC20 public oldNECO;
    INecoToken public newNECO;
    uint public necoPrice = 4;

    constructor(IERC20 _oldNECO, INecoToken _newNECO) {
        oldNECO = _oldNECO;
        newNECO = _newNECO;
    }

    function swap() external {
        uint necoAmount = oldNECO.balanceOf(msg.sender);
        require(necoAmount > 0, "Not enough NECO token.");
        oldNECO.transferFrom(msg.sender, address(this), necoAmount);
        newNECO.mint(msg.sender, necoAmount);
    }
}