// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import './interfaces/IERC20.sol';
import "./ownership/Ownable.sol";

contract ERC20 is Ownable, IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;

    


}

// Contract CentralBank
//     extension of ERC20 or self coded
//     Attributes
//         Name
//         OwnerWallet
//         CBDC_Balance_Array
//         CBDCMapping
//         Primary_Retail_Users_Array
//         Secondary_Retail_Users_Array
        
//         ERC20 vals

//     Functions
//         ERC20 Functions

//         CreateUserObj
//         TransferUserObj
//         AllowSecondaryAccess
//         Blacklist
//         Whitelist

// Contract Retail User
//     Attributes
//         Owner
//         PrimaryID
//         SecondaryIDs
//         CBDCMapping
//     Functions
//         PrintBalances
//         TranferCurrency
//         TranferObject
