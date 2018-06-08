pragma solidity ^0.4.23;

import "./Arbitration.sol";

contract Arbitrator {
    
    function createArbitration(string _reason, address _requestedBy) external returns (address) {
        return new Arbritration(_reason, _requestedBy);
    }
    
}