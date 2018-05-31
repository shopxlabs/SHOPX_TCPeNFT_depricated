pragma solidity ^0.4.24;

import "browser/Arbritration.sol";

contract Arbitrator {
    
    function createArbitration(string _reason, address _requestedBy) external returns (address) {
        return new Arbritration(_reason, _requestedBy);
    }
    
}