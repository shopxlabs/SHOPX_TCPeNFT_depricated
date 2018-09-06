pragma solidity ^0.4.24;

import "./Owned.sol";

contract ArbitrationData is Owned {
    
    mapping (address => bytes12) public arbitrationIdByAddress;
    mapping (bytes12 => address) public addressByArbitrationId;
    mapping (uint => address) public addressByIndex;
    
    uint public index;

    function save(bytes12 _arbitrationId, address _arbitrationAddress) public onlyOwner {
        arbitrationIdByAddress[_arbitrationAddress] = _arbitrationId;
        addressByArbitrationId[_arbitrationId] = _arbitrationAddress;
        addressByIndex[index] = _arbitrationAddress;
        index++;
    }   
    
}