pragma solidity ^0.4.24;

import "./Owned.sol";

//@dev This contract will not be updatable. This is used when a contract is deployed, the manager deployer is the owner. But when we update the manager contract, the asset is still owned by the old manager.
//To get around this, this contract is used to keep track of all the past managers giving the current managers rights to update data contracts.
contract ManagerData is Owned {

    //List of past and current manager addresses/wallets    
    mapping (address => bool) public managers;

    constructor() public {
        managers[msg.sender] = true;   //add creator
    }

    modifier onlyManager() {
        require(managers[msg.sender] == true);
        _;
    }

    function add(address _address) public onlyOwner {
        managers[_address] = true;
    }  
    
    function disable(address _address) public onlyOwner {
        managers[_address] = false;
    }  

    function isManager(address _address) public view returns (bool) {
        return managers[_address];
    }  
    
}