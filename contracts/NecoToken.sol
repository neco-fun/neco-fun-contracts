// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract NecoToken is ERC20("Neco Fun", "NECO"), Ownable {
    using SafeMath for uint;

    bool public transferLocked = true;
    uint public maxSupply = 1000000 * 1e18;
    uint public currentSupply = 0;

    uint public taxRate = 0;
    address public taxRecipient;
    mapping(address => bool) public taxBlackList;
    mapping(address => bool) public transferWhitelist;
    mapping (address => bool) public minters;

    bool public amountLock = true;
    uint public maxAmountPerAccount = 500 * 1e18;
    mapping(address => bool) public amountLockWhitelist;

    address public contractManager;

    constructor() {
        taxRecipient = owner();
        contractManager = owner();
    }

    function addToAmountLockWhitelist(address account) public onlyManager {
        amountLockWhitelist[account] = true;
    }

    function removeFromAmountLockWhitelist(address account) public onlyManager {
        amountLockWhitelist[account] = false;
    }

    function cancelAmountLock() public onlyManager {
        require(amountLock == true, "already canceled amount lock.");
        amountLock = false;
    }

    function changeMaxAmountPerAccount(uint newAmount) public onlyManager {
        maxAmountPerAccount = newAmount;
    }

    function changeNewManager(address manager) external onlyManager {
        contractManager = manager;
    }

    function addMinter(address account) public onlyOwner {
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
    }

    function addToTaxBlacklist(address account) external onlyManager {
        taxBlackList[account] = true;
    }

    function removeFromTaxBlacklist(address account) external onlyManager {
        taxBlackList[account] = false;
    }

    function addToTransferWhitelist(address account) external onlyManager {
        transferWhitelist[account] = true;
    }

    function removeFromTransferWhitelist(address account) external onlyManager {
        transferWhitelist[account] = false;
    }

    function changeTaxRate(uint newRate) external onlyManager {
        require(newRate <= 50, "tax rate is so high.");
        taxRate = newRate;
    }

    function changeTaxRecipient(address newAddress) external onlyManager {
        require(newAddress != address(0), "can not set 0 address.");
        taxRecipient = newAddress;
    }

    function mint(address to, uint amount) public onlyMinter {
        currentSupply = currentSupply.add(amount);
        require(currentSupply <= maxSupply, "Out of Max Supply.");
        _mint(to, amount);
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
        // Tax
        uint256 taxAmount = 0;
        if (taxBlackList[msg.sender]) {
            taxAmount = amount.mul(taxRate).div(100);
        }
        uint256 transferAmount = amount.sub(taxAmount);
        // Amount Lock
        if (amountLock && amountLockWhitelist[recipient] == false) {
            require(balanceOf(recipient).add(transferAmount) <= maxAmountPerAccount, "Out of max amount limit.");
        }
        super.transfer(recipient, transferAmount);
        if (taxAmount != 0) {
            super.transfer(taxRecipient, taxAmount);
        }
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public override returns (bool) {
        require(transferWhitelist[msg.sender] || !transferLocked, "Bad transferFrom");
        require(balanceOf(sender) >= amount, "insufficient balance.");
        // For tax
        uint256 taxAmount = 0;
        if (taxBlackList[recipient]) {
            taxAmount = amount.mul(taxRate).div(100);
        }
        uint256 transferAmount = amount.sub(taxAmount);
        // Amount Lock
        if (amountLock && amountLockWhitelist[recipient] == false) {
            require(balanceOf(recipient).add(transferAmount) <= maxAmountPerAccount, "Out of max amount limit.");
        }
        super.transferFrom(sender, recipient, transferAmount);
        if (taxAmount != 0) {
            super.transferFrom(sender, taxRecipient, taxAmount);
        }
        return true;
    }

    // once unlock transfer function, we can not lock it again.
    function unlockTransfer() external onlyManager {
        require(transferLocked == true, "Trasfer function is already unlocked.");
        transferLocked = false;
    }

    modifier onlyManager() {
        require(msg.sender == contractManager, "restrict for contract manager");
        _;
    }

    modifier onlyMinter() {
        require(minters[msg.sender], "Restricted to minters.");
        _;
    }
}