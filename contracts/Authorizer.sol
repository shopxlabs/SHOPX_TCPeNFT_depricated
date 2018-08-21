pragma solidity ^0.4.24;

contract Authorizer {
    
    mapping (address => bool) public authorizers;

    constructor() public {
        authorizers[msg.sender] = true;   
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