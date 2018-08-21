pragma solidity ^0.4.24;

contract SystemInterface {
    function addManager(address) public;
    function isApprovedManager(address) public returns (bool);    
}

contract Owned {
    
    address public owner;
    address public pendingOwner;
    
    SystemInterface systemData;

    constructor(address _systemData) public {
        // owner = msg.sender;
        systemData = SystemInterface(_systemData);
    }

    modifier onlyOwner {
        require(msg.sender == owner || systemData.isApprovedManager(msg.sender));
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
        systemData.addManager(msg.sender);
    }

}