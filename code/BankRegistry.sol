// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BankRegistry {
    address[] public banks;

    function addBank(string memory name) public {
        address newBank = address(new Bank(name));
        banks.push(newBank);
    }
}

contract Bank {
    address public bankAddress;
    ERC20 public token;
    string public name;
    mapping(address => bool) public blacklist;

    constructor(string memory _name) {
        bankAddress = address(this);
        token = new Token(_name, _name[0]);
        name = _name;
        token.mint(bankAddress, 1000 * 10 ** token.decimals());
    }

    function createRetail(address user) public {
        address newRetail = address(new Retail(user, token));
    }

    function mint(uint256 amount) public {
        require(msg.sender == bankAddress, "Only the bank can mint tokens");
        token.mint(bankAddress, amount);
    }

    function balanceOf() public view returns (uint256) {
        return token.balanceOf(bankAddress);
    }

    function transfer(address to, uint256 amount) public {
        require(msg.sender == bankAddress, "Only the bank can transfer tokens");
        require(!blacklist[to], "Destination bank is blacklisted");
        token.transfer(to, amount);
    }

    function addToBlacklist(address bank) public {
        require(msg.sender == bankAddress, "Only the bank can add to blacklist");
        blacklist[bank] = true;
    }

    function removeFromBlacklist(address bank) public {
        require(msg.sender == bankAddress, "Only the bank can remove from blacklist");
        blacklist[bank] = false;
    }

    function isBlacklisted(address bank) public view returns (bool) {
        return blacklist[bank];
    }
}

contract Retail {
    address public user;
    ERC20 public token;

    constructor(address _user, ERC20 _token) {
        user = _user;
        token = _token;
    }

    function balanceOf() public view returns (uint256) {
        return token.balanceOf(user);
    }

    function transfer(address to, uint256 amount) public {
        require(token.transferFrom(user, to, amount), "Transfer failed");
    }
}

contract Token is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}