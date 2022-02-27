// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract AirdropManager is Ownable {
    // Add the library methods
    using EnumerableSet for EnumerableSet.AddressSet;

    // Declare a set state variable
    EnumerableSet.AddressSet private airdrops;

    event AddNewAirdrop(address indexed);
    event RemoveAirdrop(address indexed);

    function addNewAirdrop(address contractAddress) external onlyOwner {
        airdrops.add(contractAddress);
        emit AddNewAirdrop(contractAddress);
    }

    function removeAirdrop(address contractAddress) external onlyOwner {
        airdrops.remove(contractAddress);
        emit RemoveAirdrop(contractAddress);
    }

    function getAirdropsLength() view external returns(uint) {
        return airdrops.length();
    }

    function getAirdropAddress(uint index) view external returns(address) {
        return airdrops.at(index);
    }
}