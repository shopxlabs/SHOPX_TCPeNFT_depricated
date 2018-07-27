pragma solidity ^0.4.24;

contract Owned {
    
    address public owner;
    address public pendingOwner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == owner);
        _;
    }

    //proposes new ownership
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    //pending owner must accept it to prevent changing to a wallet who lost their key
    function acceptOwnership(address newOwner) public onlyPendingOwner {
        owner = pendingOwner;
    }

}