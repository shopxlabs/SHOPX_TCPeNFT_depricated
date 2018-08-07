pragma solidity ^0.4.24;

import "./Owned.sol";

contract ArbitrationData is Owned {
    
    mapping (address => bytes12) public arbitrationIdByAddress;
    mapping (bytes12 => address) public addressByArbitrationId;
                                     
    uint public arbitrationId; //increments after creating new
 
    constructor() public {
        owner = msg.sender; //arbitrationManager is the owner
    }
    function save(bytes12 _arbitrationId, address _arbitrationAddress) public onlyOwner returns (bool) {
        arbitrationIdByAddress[_arbitrationAddress] = _arbitrationId;
        addressByArbitrationId[_arbitrationId] = _arbitrationAddress;
        return true;
    }  
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (bytes12) {
        return arbitrationIdByAddress[_arbitrationAddress];
    }    
    
    function getAddressByArbitrationId(bytes12 _arbitrationId) public view returns (address) {
        return addressByArbitrationId[_arbitrationId];
    }    

    
}