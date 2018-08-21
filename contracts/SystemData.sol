pragma solidity ^0.4.24;

import "./Owned.sol";

contract SystemData is Owned {
    
    mapping (address => bool) public approvedManagers;


    constructor() public {
        owner = msg.sender; //ownerManager is the owner
    }

    function addManager(address _manager) public onlyOwner {
        approvedManagers[_manager] = true;
    }  

    function isApprovedManager() public view returns (bool) {
        return approvedManagers[msg.sender];
    }  

    // function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (bytes12) {
    //     return arbitrationIdByAddress[_arbitrationAddress];
    // }    
    
    // function getAddressByArbitrationId(bytes12 _arbitrationId) public view returns (address) {
    //     return addressByArbitrationId[_arbitrationId];
    // }    
    
}