// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

contract Owned {
    
    address public owner;
    address public pendingOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPendingOwner {
        require(msg.sender == pendingOwner);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //@dev proposes new manager ownership
    function transferOwnership(address newOwner) public onlyOwner {
        pendingOwner = newOwner;
    }

    //@dev pending owner must accept it to prevent changing to a wallet who lost their key
    function acceptOwnership() public onlyPendingOwner {
        owner = pendingOwner;
    }


}