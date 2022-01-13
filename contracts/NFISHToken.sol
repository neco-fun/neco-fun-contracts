// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NecoFishingToken is ERC20("NecoFishing", "NFISH"), Ownable {
    bool public transferLocked = true;

    mapping (address=>bool) public minters;
    mapping (address=>bool) public burners;

    // time lock for operations.
    mapping (string=>uint) public operationUnlockTime;
    string private MINT = "mint";
    string private TRANSFER = "transfer";
    bool public mintOperationForOwnerLocked = false;
    bool public lockTransferOperationForOwnerLocked = false;

    address public mintTo = address(0);
    uint public mintAmount = 0;
    uint public unlockDuration = 2 days;

    event AddMinter(address account);
    event RemoveMinter(address account);
    event AddBurner(address account);
    event RemoveBurner(address account);
    event TransferUnlocked(bool result);

    /**
        Minter operations
     */
    function addMinter(address account) external onlyOwner {
        require(account != address(0), "You can not add address 0");
        minters[account] = true;
        emit AddMinter(account);
    }

    function removeMinter(address account) external onlyOwner {
        minters[account] = false;
        emit RemoveMinter(account);
    }

    function addBurner(address account) external onlyOwner {
        require(account != address(0), "You can not add address 0");
        burners[account] = true;
        emit AddBurner(account);
    }

    function removeBurner(address account) external onlyOwner {
        burners[account] = false;
        emit RemoveBurner(account);
    }

    /**
        Mint operations
     */

    //  owner can not mint NCFH token when mintOperationForOwnerLocked = true.
    // so owner should use time lock function to mint NCFH tokens.
    function mint(address to, uint amount) external onlyMinter {
        if (mintOperationForOwnerLocked) {
            require(msg.sender != owner(), "Owner can not mint token for now.");
        }
        _mint(to, amount);
    }

    // pend mint operation for owner
    function goingToMint(address to, uint amount) external onlyOwner {
        require(to != address(0), "Can not mint token to zero address!");
        mintTo = to;
        mintAmount = amount;
        operationUnlockTime[MINT] = block.timestamp + unlockDuration;
    }

    // release mint operation for owner.
    function releaseMint() external onlyOwner {
        require(mintAmount > 0, "mint amount can not be 0");
        require(operationUnlockTime[MINT] != 0, "Bad operationUnlockTime");
        require(block.timestamp >= operationUnlockTime[MINT], "Mint operation is locked.");
        _mint(mintTo, mintAmount);
        mintTo = address(0);
        mintAmount = 0;
        operationUnlockTime[MINT] = 0;
    }

    function changeUnlockTimeDuration(uint newDuration) external onlyOwner {
        require(newDuration >= 1 days, "Can not change duration to 0");
        unlockDuration = newDuration;
    }

    /**
        Burn operations
     */
    function burn(uint amount) external returns(bool) {
        require(amount > 0, "can not burn 0 token");
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
        return true;
    }

    function burnFrom(address sender, uint amount) external onlyBurner returns(bool) {
        require(amount > 0 && sender != address(0), "Burn amount or address is 0");
        _burn(sender, amount);
        return true;
    }

    /**
        Transfer operations
     */
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

    function unlockTransfer() external onlyOwner {
        transferLocked = false;
        emit TransferUnlocked(transferLocked);
    }

    // if owner want to lock transfer function. should wait 2 days.
    function goingToLocakTransferFunction() external onlyOwner {
        require(!transferLocked, "Transfer function has been locked.");
        operationUnlockTime[TRANSFER] = block.timestamp + unlockDuration;
    }

    function releaseTransferLock() external onlyOwner {
        if(lockTransferOperationForOwnerLocked) {
            require(block.timestamp >= operationUnlockTime[TRANSFER], "can not lock transfer function.");
        }
        transferLocked = true;
    }

    /**
        Lock operations
     */
    function enableMintOperationForOwnerLocked() public onlyOwner {
        mintOperationForOwnerLocked = true;
    }

    function enableLockTransferOperationForOwnerLocked() public onlyOwner {
        lockTransferOperationForOwnerLocked = true;
    }

    /**
        modifiers
     */
    modifier onlyMinter() {
        require(minters[msg.sender], "Restricted to minters.");
        _;
    }

    modifier onlyBurner() {
        require(burners[msg.sender], "Restricted to burners.");
        _;
    }
}