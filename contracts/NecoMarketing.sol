// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./INecoToken.sol";

contract NecoMarketing is Ownable {
    using SafeMath for uint;

    uint public maxMarketingFund = 50000 * 1e18;
    uint public maxAirdropFund = 20000 * 1e18;

    INecoToken public neco;

    constructor(INecoToken _neco) {
        neco = _neco;
    }

    function unlockMarketingFund(address account, uint amount) external onlyOwner {
        require(amount > 0 && amount <= maxMarketingFund, "Amounf cannot be 0.");
        neco.mint(account, amount);
        maxMarketingFund = maxMarketingFund.sub(amount);
    }

    function unlockAirdropFund(address account, uint amount) external onlyOwner {
        require(amount > 0 && amount <= maxAirdropFund, "Amounf cannot be 0.");
        neco.mint(account, amount);
        maxAirdropFund = maxAirdropFund.sub(amount);
    }
}