// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract NecoAirdrop is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;

    mapping (address=>bool) public whitelist;
    mapping (address=> bool) public claimed;
    bool public initialized = false;
    bool claimEnabled = false;

    IERC20 public necoToken;
    // 20 neco for everyone， winner 200 people
    uint public necoTotalAmount = 4000 * 1e18;
    uint public necoAmountForEveryone = 20 * 1e18;

    // for that time, we may need to add whitelist 1 by 1, or we may init them at one time.
    constructor(IERC20 _necoToken) {
        necoToken = _necoToken;
        initWhitelist();
    }

    // start sale
    function startClaim() external onlyOwner {
        require(initialized, "Need to call initData firstly.");
        claimEnabled = true;
    }

    function stopClaim() external onlyOwner {
        claimEnabled = false;
    }

    function getNecoBalance() view external returns(uint) {
        return necoToken.balanceOf(address(this));
    }

    // this contract will be deployed on Polygon, So we should deposit NECO tokens
    // into this contract and setup its status.
    function initData() external onlyOwner {
        necoToken.transferFrom(msg.sender, address(this), necoTotalAmount);
        initialized = true;
    }

    function claim() external claimHasStarted {
        require(whitelist[msg.sender], "you are not in airdrop winner list.");
        require(claimed[msg.sender] == false, "you already claimed NECO.");

        necoToken.transfer(msg.sender, necoAmountForEveryone);
        claimed[msg.sender] = true;
    }

    function initWhitelist() internal {
        whitelist[0x3c5de42f02DebBaA235f7a28E4B992362FfeE0B6] = true;
    }

    modifier claimHasStarted() {
        require(claimEnabled, "sale has not been started.");
        _;
    }
}