// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./ownership/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";

contract CBDC is Ownable, IERC20 {
    string public name;
    string public currency;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    mapping(string => address) internal primaryRetailUsers;

    mapping(uint256 => string) internal UserMapping;
    uint256 public numUsers;

    constructor(
        string memory _name,
        string memory _currency,
        uint8 _decimals,
        uint256 _totalSupply
    ) {
        currency = _currency;
        name = _name;
        decimals = _decimals;
        _balances[msg.sender] = _totalSupply;
        totalSupply = _totalSupply;
    }

    function transfer(
        address _to,
        uint256 _value
    ) external override returns (bool) {
        require(_to != address(0), "ERC20: to address is not valid");
        require(_value <= _balances[msg.sender], "ERC20: insufficient balance");

        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;

        return true;
    }

    function balanceOf(
        address _addr
    ) external view override returns (uint256 balance) {
        // only u and owner access balance
        return _balances[_addr];
    }

    function mint(uint256 _amount) external onlyOwner returns (bool) {
        _balances[owner] = _balances[owner] + _amount;
        totalSupply = totalSupply + _amount;

        return true;
    }

    function createRetailUser(
        string memory _name,
        address _newOwner
    ) external onlyOwner returns (bool) {
        RetailUser retailUser = new RetailUser(
            _name,
            name,
            address(this),
            currency
        );
        primaryRetailUsers[_name] = address(retailUser);
        retailUser.transferOwnership(_newOwner);

        return true;
    }

    function accessUserAddress(
        string memory _name
    ) external view onlyOwner returns (address) {
        address temp = primaryRetailUsers[_name];
        return temp;
    }
}

contract RetailUser is Ownable {
    string public name;
    string public CreatorName;
    address public CreatorAddress;
    string public PrimaryCurrency;
    mapping(string => address) public CBDCAddresses;
    // hold all currencies string[] currencies;
    string[] public HeldCurrencies;

    // mapping (address => string) public Certificates;

    constructor(
        string memory _name,
        string memory _creatorName,
        address _creatorAddr,
        string memory _primaryCurrency
    ) {
        name = _name;
        CreatorName = _creatorName;
        CreatorAddress = _creatorAddr;
        PrimaryCurrency = _primaryCurrency;
        CBDCAddresses[_primaryCurrency] = _creatorAddr;
        HeldCurrencies.push(_primaryCurrency);
        //hold currencies
        //hold certificates
    }

    function transferCurrency(
        string memory _currency,
        address _to,
        uint256 _value
    ) public {
        address currency_addr = CBDCAddresses[_currency];
        CBDC tempAcces = CBDC(currency_addr);
        tempAcces.transfer(_to, _value);
    }

    function printBalance(
        string memory _currency
    ) public view returns (uint256 balance) {
        address currency_addr = CBDCAddresses[_currency];
        CBDC tempAcces = CBDC(currency_addr);
        return tempAcces.balanceOf(address(this));
    }

    function printAllBalances() public view returns (string memory) {
        string memory result = "";

        for (uint i = 0; i < HeldCurrencies.length; i++) {
            string memory currencyName = HeldCurrencies[i];
            // address currency_addr = CBDCAddresses[currencyName];
            // CBDC tempAcces = CBDC(currency_addr);
            // uint256 balance = tempAcces.balanceOf(address(this));
            uint256 balance = printBalance(currencyName);
            // bytes memory balanceBytes = abi.encodePacked(balance);
            // bytes memory balanceStringBytes = new bytes(balanceBytes.length);
            // for (uint j = 0; j < balanceBytes.length; j++) {
            //     balanceStringBytes[j] = bytes1(uint8(balanceBytes[j]) + 48);
            // }
            result = string(
                abi.encodePacked(
                    result,
                    currencyName,
                    " balance: ",
                    Strings.toString(balance),
                    "\n"
                )
            );
        }

        return result;
    }

    function addNewCurrency(
        string memory _new_currency,
        address _new_currency_address
    ) public returns (bool) {
        // Call parent CBDC for address of user
        CBDCAddresses[_new_currency] = _new_currency_address;
        HeldCurrencies.push(_new_currency);
        return true;
    }
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
