// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ownership/Ownable.sol";

contract BankOfBanks is Ownable {
    string public name;

    string[] public countries;
    mapping(string => string) country_to_curencies;
    mapping(string => address) currency_to_addresses;
    mapping(address => string) address_to_country;

    constructor(string memory _name) {
        name = _name;
    }

    function country_addr(
        string memory _name
    ) external view returns (address countryAddr) {
        return currency_to_addresses[country_to_curencies[_name]];
    }

    function register_country(
        string memory _name,
        string memory _currency,
        address _country_addr
    ) external returns (bool) {
        // requires encrypted password with a decryption key at BankOfBanks for registering
        countries.push(_name);
        country_to_curencies[_name] = _currency;
        currency_to_addresses[_currency] = _country_addr;
        address_to_country[_country_addr] = _name;
        return true;
    }

    function request_address(
        string memory _req_currency
    ) public view returns (address) {
        require(
            bytes(address_to_country[msg.sender]).length > 0,
            "Sender is not in the address_to_country mapping"
        );

        address addr = currency_to_addresses[_req_currency];
        require(
            addr != address(0),
            "No address found for the requested currency"
        );

        return addr;
    }
}
