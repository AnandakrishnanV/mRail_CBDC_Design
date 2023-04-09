// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";
import "./ownership/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/Strings.sol";
import "./BankOfBanks.sol";

contract CentralBank is Ownable, IERC20 {
    // Name, Currency tag, No.of decimals and Total Supply of the currency
    // of the Bank
    string public name;
    string public currency;
    uint8 public decimals;
    uint256 public totalSupply;

    // Stores the address of the controller bank
    address BankOfBanksAddr;

    // Addresses of each foreign currency on the chain
    mapping(string => address) internal currency_to_addresses;

    // Status is a number to indicate strength of access - will be decided on 
    // and used for txn implementation
    // Used to decide your counries restrictions on other currencies
    mapping(string => uint8) internal internal_users_all_currency_status;

    mapping(string => uint8) internal foreign_country_internal_restrictions;

    // Stores balances of each currency type held by the CB, including their own
    // ???
    mapping(address => uint256) internal _balances;

    // Details of Primary Users i.e citizens under the Bank's jurisdiction
    mapping(string => address) internal primaryUserAddresses;
    mapping(uint256 => string) internal primaryUserData;
    uint256 public primaryNumUsers;
    mapping(address => uint8) internal primaryUserStatus;

    // Details of Secondary Users i.e. users from other countries
    // country because foregin bank only makes ties with COuntry not the currency it holds
    // i.e Japan India not Japan INR
    mapping(string => uint256) internal secondaryUserCountryUsers;
    mapping(string => mapping(uint256 => address)) secondaryUserAddresses;
    mapping(address => string) secondaryUserData;
    mapping(address => uint8) secondaryUserStatus;

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
        currency_to_addresses[currency] = address(this);
        
        internal_users_all_currency_status[_currency] = 99;

        primaryNumUsers = 1;
        primaryUserStatus[address(this)] = 99;
        primaryUserData[0] = _name;
        primaryUserAddresses[_name] = address(this);
    }

    function register_with_BankOfBanks(
        address _BankOfBanksAddr
    ) external onlyOwner returns (address) {
        BankOfBanksAddr = _BankOfBanksAddr;
        BankOfBanks tempAccess = BankOfBanks(_BankOfBanksAddr);

        tempAccess.register_country(name, currency, address(this));

        address tempAddr = tempAccess.request_address(currency);

        return tempAddr;
    }

    function find_currency_address(
        string memory _currency
    ) public returns (address) {
        address ans = currency_to_addresses[_currency];
        if (ans == address(0)) {
            BankOfBanks tempAccess = BankOfBanks(BankOfBanksAddr);
            ans = tempAccess.request_address(_currency);
            require(ans != address(0), "No address found for the given key");
            currency_to_addresses[_currency] = ans;
            internal_users_all_currency_status[_currency] = 0;
        }
        require(ans != address(0), "No address found for the given key");
        return ans;
    }

    function change_internal_users_all_currency_status(
        string memory _currency,
        uint8 _newStatus
    ) external onlyOwner returns (bool) {
        // Setting INR status for your primary users
        address ans = find_currency_address(_currency);
        require(ans != address(0),"Bank address not found");
        internal_users_all_currency_status[_currency] = _newStatus;
        return true;
    }

    function change_foreign_country_internal_restrictions_status(
        string memory _country,
        uint8 _newStatus
    ) public onlyOwner returns (bool) {
        // Setting What Indians using JPY face
        foreign_country_internal_restrictions[_country] = _newStatus;
        return true;
    }

    function internal_currency_transfer_allowed(
        address addr
    ) internal view returns (uint8) {
        uint8 status = primaryUserStatus[addr];
        if (status == 0) {
            status = secondaryUserStatus[addr];
        }
        return status;
    }

    function transfer(
        address _to,
        uint256 _value
    ) external override returns (bool) {
        require(_to != address(0), "ERC20: to address is not valid");
        require(_value <= _balances[msg.sender], "ERC20: insufficient balance");
        require(internal_currency_transfer_allowed(msg.sender)>0,"sender invalid");
        require(internal_currency_transfer_allowed(_to)>0,"reciever invalid");

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
        primaryUserData[primaryNumUsers] = _name;
        primaryUserAddresses[_name] = address(retailUser);
        primaryUserStatus[address(retailUser)] = 9;
        primaryNumUsers += 1;

        retailUser.transferOwnership(_newOwner);

        return true;
    }

    function accessPrimaryUserAddress(
        string memory _name
    ) external view onlyOwner returns (address) {
        address temp = primaryUserAddresses[_name];
        return temp;
    }

    function requestAccessToNewCurrency(
        string memory _currency,
        string memory _user_data
    ) external returns (address) {
        //check if primary user
        require(primaryUserStatus[msg.sender]>0,"Sender Invalid Status");
        require(internal_users_all_currency_status[_currency]>0,"Currency status invalid");
        CentralBank tempAccess = CentralBank(currency_to_addresses[_currency]);
        address foreign_address = tempAccess.CreateSecondaryUser(currency, name, _user_data, msg.sender);

        return foreign_address;
    }

    function CreateSecondaryUser (
        string memory _source_currency,
        string memory _source_country,
        string memory _user_data,
        address _user_addr
    ) public returns (address) {
        address foreign_country_addr_check = find_currency_address(_source_currency);
        require(msg.sender == foreign_country_addr_check, "BAD REQUEST");

        require(foreign_country_internal_restrictions[_source_country]>0,"Not allowed to create user");

        secondaryUserAddresses[_source_country][secondaryUserCountryUsers[_source_country]] = _user_addr;
        secondaryUserCountryUsers[_source_country] += 1;
        secondaryUserData[_user_addr] = _user_data;
        secondaryUserStatus[_user_addr] = foreign_country_internal_restrictions[_source_country];

        return address(this);
    }

    function change_all_foreign_country_wallet_status (
        string memory _country,
        uint8 _newStatus
    ) public onlyOwner returns (bool) {
        foreign_country_internal_restrictions[_country] = _newStatus;
        for (uint256 i = 0; i < secondaryUserCountryUsers[_country]; i++) {
            secondaryUserStatus[secondaryUserAddresses[_country][i]] = _newStatus;
        }
        return true;
    }

    function change_primary_user_status (
        address _addr,
        uint8 _newStatus
    ) public onlyOwner returns (bool) {
        // Need to add check for non user
        // might accidentaly set secondary user as primary user using this
        // can be mitgated with -1,0,1 scheme in naming values or 
        // different int schemes
        primaryUserStatus[_addr] = _newStatus;
        return true;
    }

    function change_secondary_user_status (
        address _addr,
        uint8 _newStatus
    ) public onlyOwner returns (bool) {
        // Need to add check for primary user
        // might accidentaly set primary user as secondary user using this
        // can be mitgated with -1,0,1 scheme in naming values or 
        // different int schemes
        secondaryUserStatus[_addr] = _newStatus;
        return true;
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
        CentralBank tempAcces = CentralBank(currency_addr);
        tempAcces.transfer(_to, _value);
    }

    function printBalance(
        string memory _currency
    ) public view returns (uint256 balance) {
        address currency_addr = CBDCAddresses[_currency];
        CentralBank tempAcces = CentralBank(currency_addr);
        return tempAcces.balanceOf(address(this));
    }

    function printAllBalances() public view returns (string memory) {
        string memory result = "";

        for (uint i = 0; i < HeldCurrencies.length; i++) {
            string memory currencyName = HeldCurrencies[i];
            uint256 balance = printBalance(currencyName);
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

    function requestNewCurrency(
        string memory _new_currency
    ) public onlyOwner returns (bool) {       
        CentralBank tempAcces = CentralBank(CreatorAddress);
        address new_currency_address = tempAcces.requestAccessToNewCurrency(_new_currency, name);
        require(new_currency_address != address(0), "New currency addition failed");
        CBDCAddresses[_new_currency] = new_currency_address;
        HeldCurrencies.push(_new_currency);
        return true;        
    }

    // function addNewCurrency(
    //     string memory _new_currency,
    //     address _new_currency_address
    // ) public returns (bool) {
    //     // Call parent CBDC for address of user
    //     CBDCAddresses[_new_currency] = _new_currency_address;
    //     HeldCurrencies.push(_new_currency);
    //     return true;
    // }
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
