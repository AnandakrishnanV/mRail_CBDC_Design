// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import './interfaces/IERC20.sol';
import "./ownership/Ownable.sol";

contract ERC20 is Ownable, IERC20 {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;

    constructor (string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        _balances[msg.sender] = _totalSupply;
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_value <= _balances[msg.sender], 'ERC20: insufficient balance');

        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;
        
        return true;
    }

    function balanceOf(address _owner) external override view returns (uint256 balance) {
        return _balances[_owner];
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_value <= _balances[_from], 'ERC20: insufficient balance');
        require(_value <= _allowed[_from][msg.sender], 'ERC20: transfer from value not allowed');

        _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _value;
        _balances[_from] = _balances[_from] - _value;
        _balances[_to] = _balances[_to] + _value;
                
        return true;
   }

   function allowance(address _owner, address _spender) external override view returns (uint256) {
        return _allowed[_owner][_spender];
    }

    function mintTo(address _to,uint256 _amount) external onlyOwner returns (bool) {
        require(_to != address(0), 'ERC20: to address is not valid');

        _balances[_to] = _balances[_to] + _amount;
        totalSupply = totalSupply + _amount;

        return true;
    }

    function burn(uint256 _amount) external returns (bool) {
        require(_balances[msg.sender] >= _amount, 'ERC20: insufficient balance');

        _balances[msg.sender] = _balances[msg.sender] - _amount;
        totalSupply = totalSupply - _amount;

        return true;
    }


}

