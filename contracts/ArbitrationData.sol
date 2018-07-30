pragma solidity ^0.4.24;

import "./Managed.sol";

contract ArbitrationData is Managed {
    
    mapping (address => uint) public arbitrationIdByAddress;
    mapping (uint => address) public addressByArbitrationId;
                                     
    uint public arbitrationId; //increments after creating new
 
    function save(address _arbitrationAddress) public onlyManager returns (bool success) {
        arbitrationIdByAddress[_arbitrationAddress] = arbitrationId;
        addressByArbitrationId[arbitrationId] = _arbitrationAddress;
        arbitrationId++;
        return true;
    }  
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (uint) {
        return arbitrationIdByAddress[_arbitrationAddress];
    }    
    
    function getAddressByArbitrationId(uint _arbitrationId) public view returns (address) {
        return addressByArbitrationId[_arbitrationId];
    }    

    
}