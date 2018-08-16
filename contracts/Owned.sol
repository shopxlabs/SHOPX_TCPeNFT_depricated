pragma solidity ^0.4.24;

contract Owned {
    
    address public owner;
    address public pendingOwner;

    constructor() public {
        // owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == pendingOwner);
        _;
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