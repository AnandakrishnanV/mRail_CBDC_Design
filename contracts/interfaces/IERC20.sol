// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    // function allowance(address owner, address spender) external view returns (uint256);
    // function transferFrom(address from, address to, uint256 value) external returns (bool);
}
