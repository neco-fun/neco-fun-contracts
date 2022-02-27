// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INecoToken.sol";

contract NecoAirdrop is Ownable {
    using SafeMath for uint;

    mapping (address=>bool) public whitelist;
    mapping (address=> bool) public claimed;
    bool claimEnabled = false;

    INecoToken public necoToken;
    // 20 neco for everyone， winner 200 people
    uint public necoTotalClaimedAmount = 0;
    uint public necoAmountForEveryone = 20 * 1e18;

    // for that time, we may need to add whitelist 1 by 1, or we may init them at one time.
    constructor(INecoToken _necoToken) {
        necoToken = _necoToken;
        initWhitelist();
    }

    // start sale
    function enableClaim() external onlyOwner {
        claimEnabled = true;
    }

    function stopClaim() external onlyOwner {
        claimEnabled = false;
    }

    function claim() external claimHasStarted {
        require(whitelist[msg.sender], "you are not in airdrop winner list.");
        require(claimed[msg.sender] == false, "you already claimed NECO.");

        necoToken.transfer(msg.sender, necoAmountForEveryone);
        necoTotalClaimedAmount = necoTotalClaimedAmount.add(necoAmountForEveryone);
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