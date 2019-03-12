pragma solidity ^0.5.1;

import './Harvester.sol';
import './Manufacturer.sol';
import './Distributor.sol';
import './Retailer.sol';
import './Consumer.sol';

contract AccessControl is DesignerRole, VerifierRole, PlayerRole {

    constructor() public {

    }

}
