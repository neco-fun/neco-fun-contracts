// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INecoToken {
    function whitelist(address account) external returns(bool);
    function claimed(address account) external returns(bool);
    function claim() external;
}
