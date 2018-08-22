pragma solidity ^0.4.24;

//@desc This contract will not be updatable. This is used when a contract is deployed, the manager deployer is the owner. But when we update the manager contract, the asset is still owned by the old manager.
//To get around this, this contract is used to keep track of all the past managers giving the current managers rights to update those contracts.
contract Authorizer {

    //List of past and current manager addresses/wallets    
    mapping (address => bool) public authorizers;

    constructor() public {
        authorizers[msg.sender] = true;   //add creator
    }

    modifier onlyAuthorized() {
        require(authorizers[msg.sender] == true);
        _;
    }

    function add(address _address) public onlyAuthorized {
        authorizers[_address] = true;
    }  
    
    function disable(address _address) public onlyAuthorized {
        authorizers[_address] = false;
    }  

    function isAuthorized(address _address) public view returns (bool) {
        return authorizers[_address];
    }  
    
}