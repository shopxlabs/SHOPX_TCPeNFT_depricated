pragma solidity ^0.4.24;

import "./Owned.sol";

contract ArbitrationData is Owned {
    
    mapping (address => bytes12) public arbitrationIdByAddress;
    mapping (bytes12 => address) public addressByArbitrationId;
    mapping (uint => address) public addressByIndex;
    
    uint public arbitrationId; //increments after creating new
    uint public arbitrationIndex;

    constructor() public {
        owner = msg.sender; //arbitrationManager is the owner
    }

    function save(bytes12 _arbitrationId, address _arbitrationAddress) public onlyOwner {
        arbitrationIdByAddress[_arbitrationAddress] = _arbitrationId;
        addressByArbitrationId[_arbitrationId] = _arbitrationAddress;
        addressByIndex[arbitrationIndex] = _arbitrationAddress;
        arbitrationIndex++;
    }  
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (bytes12) {
        return arbitrationIdByAddress[_arbitrationAddress];
    }    
    
    function getAddressByArbitrationId(bytes12 _arbitrationId) public view returns (address) {
        return addressByArbitrationId[_arbitrationId];
    }    

    function getAddressByIndex(uint _index) public view returns (address) {
        return addressByIndex[_index];
    }    
    
}