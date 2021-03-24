// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "../Utils/Owned.sol";

contract ArbitrationData is Owned {
    
    mapping (address => bytes12) public arbitrationIdByAddress;
    mapping (bytes12 => address) public addressByArbitrationId;
    mapping (uint => address) public addressByIndex;
    
    uint public index;
    //TODO: add modifier t only let new
    function save(bytes12 _arbitrationId, address _arbitrationAddress) public onlyOwner {
        arbitrationIdByAddress[_arbitrationAddress] = _arbitrationId;
        addressByArbitrationId[_arbitrationId] = _arbitrationAddress;
        addressByIndex[index] = _arbitrationAddress;
        index++;
    }   
    
}