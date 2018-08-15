pragma solidity ^0.4.24;

import "./Owned.sol";

contract UserData is Owned {
    
    mapping (address => address) public users;

    constructor() public {
        owner = msg.sender; //ownerManager is the owner
    }

    function save(address _userWallet, address _userContract) public onlyOwner {
        users[_userWallet] = _userContract;
    }  
    
    // function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (bytes12) {
    //     return arbitrationIdByAddress[_arbitrationAddress];
    // }    
    
    // function getAddressByArbitrationId(bytes12 _arbitrationId) public view returns (address) {
    //     return addressByArbitrationId[_arbitrationId];
    // }    
    
}