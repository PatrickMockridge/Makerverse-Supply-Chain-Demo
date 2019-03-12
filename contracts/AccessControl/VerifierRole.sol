pragma solidity ^0.5.1;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'VerifierRole' to manage this role - add, remove, check
contract VerifierRole {
  using Roles for Roles.Role;

  // Define 2 events, one for Adding, and other for Removing
  event VerifierAdded(address indexed account);
  event VerifierRemoved(address indexed account);

  // Define a struct 'verifiers' by inheriting from 'Roles' library, struct Role
  Roles.Role private verifiers;

  // In the constructor make the address that deploys this contract the 1st Verifier
  constructor() public {
    _addVerifier(msg.sender);
  }

  // Define a modifier that checks to see if msg.sender has the appropriate role
  modifier onlyVerifier() {
    require(isVerifier(msg.sender));
    _;
  }

  // Define a function 'isVerifier' to check this role
  function isVerifier(address account) public view returns (bool) {
    return verifiers.has(account);
  }

  // Define a function 'addVerifier' that adds this role
  function addVerifier(address account) public onlyDesigner {
    _addVerifier(account);
  }

  // Define a function 'renounceVerifier' to renounce this role
  function renounceVerifier() public {
    _removeVerifier(msg.sender);
  }

  // Define an internal function '_addVerifier' to add this role, called by 'addHarvester'
  function _addVerifier(address account) internal {
    verifiers.add(account);
    emit VerifiersAdded(account);
  }

  // Define an internal function '_removeVerifier' to remove this role, called by 'removeHarvester'
  function _removeVerifier(address account) internal {
    verifiers.remove(account);
    emit VerifierRemoved(account);
  }
}
