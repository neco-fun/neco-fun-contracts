// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NecoToken is ERC20("NecoFun", "NECO"), Ownable {
    using SafeMath for uint;

    bool public transferLocked = true;
    uint private _mintAmount = 1000000 * 1e18;

    uint public taxRate = 0;
    address public taxRecipient;
    mapping(address => bool) public taxWhiteList;
    mapping(address => bool) public transferWhitelist;

    event TransferUnlocked(bool result);

    // when this contract is deployed, it will mint 1,000,000 NECO tokens on BSC.
    constructor() {
        _mint(owner(), _mintAmount);
        taxRecipient = owner();
    }

    function addToTaxWhitelist(address account) external onlyOwner {
        taxWhiteList[account] = true;
    }

    function removeFromTaxWhitelist(address account) external onlyOwner {
        taxWhiteList[account] = false;
    }

    function addToTransferWhitelist(address account) external onlyOwner {
        transferWhitelist[account] = true;
    }

    function removeFromTransferTaxWhitelist(address account) external onlyOwner {
        transferWhitelist[account] = false;
    }

    function changeTaxRate(uint newRate) external onlyOwner {
        require(newRate <= 50, "tax rate is so high.");
        taxRate = newRate;
    }

    function changeTaxRecipient(address newAddress) external onlyOwner {
        require(newAddress != address(0), "can not set 0 address.");
        taxRecipient = newAddress;
    }

    // only user can burn their own NECO tokens.
    function burn(uint amount) external {
        require(amount > 0);
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
    }

    function transfer(address recipient, uint amount) public override returns(bool) {
        require(transferWhitelist[msg.sender] || !transferLocked, "Bad Transfer");
        require(balanceOf(msg.sender) >= amount, "insufficient balance.");

        uint256 taxAmount = amount.mul(taxRate).div(100);
        if (taxWhiteList[msg.sender] || taxWhiteList[recipient]) {
            taxAmount = 0;
        }
        uint256 transferAmount = amount.sub(taxAmount);
        require(balanceOf(msg.sender) >= amount, "insufficient balance.");
        super.transfer(recipient, transferAmount);
        if (taxAmount != 0) {
            super.transfer(taxRecipient, taxAmount);
        }
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        require(transferWhitelist[msg.sender] || !transferLocked, "Bad transferFrom");
        require(balanceOf(sender) >= amount, "insufficient balance.");

        uint256 taxAmount = amount.mul(taxRate).div(100);
        if (taxWhiteList[msg.sender] || taxWhiteList[recipient]) {
            taxAmount = 0;
        }
        uint256 transferAmount = amount.sub(taxAmount);
        require(balanceOf(sender) >= amount, "insufficient balance.");
        super.transferFrom(sender, recipient, transferAmount);
        if (taxAmount != 0) {
            super.transferFrom(sender, taxRecipient, taxAmount);
        }
        return true;
    }

    // once unlock transfer function, we can not lock it again.
    function unlockTransfer() external onlyOwner {
        transferLocked = false;
        emit TransferUnlocked(transferLocked);
    }
}