pragma solidity ^0.5.1;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'ConsumerRole' to manage this role - add, remove, check
contract PlayerRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event PlayerAdded(address indexed account);
  event PlayerRemoved(address indexed account);

  // Define a struct 'Consumers' by inheriting from 'Roles' library, struct Role
  Roles.Role private players;

  // In the constructor make the address that deploys this contract the 1st Consumer
  constructor() public {
    _addPlayer(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyPlayer() {
    require(isPlayer(msg.sender));
    _;
  }

  // Define a function 'isConsumer' to check this role
  function isPlayer(address account) public view returns (bool) {
    return consumers.has(account);
  }

  // Define a function 'addConsumer' that adds this role
  function addPlayer(address account) public onlyPlayer {
    _addPlayer(account);
  }

  // Define a function 'renounceConsumer' to renounce this role
  function renouncePlayer() public {
    _removePlayer(msg.sender);
  }

  // Define an internal function '_addConsumer' to add this role, called by 'addConsumer'
  function _addPlayer(address account) internal {
    players.add(account);
    emit PlayerAdded(account);
  }

  // Define an internal function '_removeConsumer' to remove this role, called by 'removeConsumer'
  function _removePlayer(address account) internal {
    players.remove(account);
    emit PlayerRemoved(account);
  }
}
