// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NecoToken is ERC20("NecoFun", "NECO"), Ownable {
    bool public transferLocked = true;
    uint private _mintAmount = 1000000 * 1e18;

    event TransferUnlocked(bool result);

    // when this contract is deployed, it will mint 1,000,000 NECO tokens on BSC.
    constructor() {
        _mint(owner(), _mintAmount);
    }

    // only user can burn their own NECO tokens.
    function burn(uint amount) external {
        require(amount > 0);
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint amount) public override returns(bool) {
        require(msg.sender == owner() || !transferLocked, "Bad Transfer");
        require(balanceOf(msg.sender) >= amount, "insufficient balance.");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        require(sender == owner() || !transferLocked, "Bad transferFrom");
        require(balanceOf(sender) >= amount, "insufficient balance.");
        return super.transferFrom(sender, recipient, amount);
    }

    // once unlock transfer function, we can not lock it again.
    function unlockTransfer() external onlyOwner {
        transferLocked = false;
        emit TransferUnlocked(transferLocked);
    }
}