// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FarmingLPToken is ERC20("FarmingLPToken", "LPTN"), Ownable {
    function mint(address to, uint amount) external onlyOwner {
        require(amount > 0, "Cannot mint 0 token.");
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function burn(uint amount) external {
        require(amount > 0);
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
    }
}