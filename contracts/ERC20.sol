// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import './interfaces/IERC20.sol';
import "./ownership/Ownable.sol";

contract ERC20 is Ownable, IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;

    


}

