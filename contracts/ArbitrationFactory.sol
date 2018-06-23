pragma solidity ^0.4.24;

import "./Arbitration.sol";

contract ArbitrationFactory {
    
    function createArbitration(string _reason, address _requestedBy) external returns (address) {
        return new Arbritration(_reason, _requestedBy);
    }
    
}

