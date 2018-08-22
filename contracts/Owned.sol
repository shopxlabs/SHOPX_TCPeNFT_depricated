pragma solidity ^0.4.24;

contract AuthorizerInterface {
    function isAuthorized(address) public returns (bool);
    function add(address) public;
}


contract Owned {
    
    address public owner;
    address public pendingOwner;
    AuthorizerInterface public authorizer;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == pendingOwner);
        _;
    }

    modifier onlyAuthorized {
        require(authorizer.isAuthorized(msg.sender) == true);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    //proposes new manager ownership
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    //pending owner must accept it to prevent changing to a wallet who lost their key
    function acceptOwnership() public onlyPendingOwner {
        owner = pendingOwner;
    }


}