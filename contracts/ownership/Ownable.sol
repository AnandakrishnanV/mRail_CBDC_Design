// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Ownable {
  address public owner;

    event TransferOwnership(address formerOwner, address newOwner);

  constructor(){
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address _newOwner) public virtual onlyOwner {
    _transferOwnership(_newOwner);
  }

 
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0), 'Ownable: address is not valid');
    owner = _newOwner;
    emit TransferOwnership(msg.sender, _newOwner);
  }
}