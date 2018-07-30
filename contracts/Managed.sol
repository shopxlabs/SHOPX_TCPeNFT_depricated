pragma solidity ^0.4.24;
import "./Owned.sol";

contract Managed is Owned {

    address public manager;

    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }
    //@desc security for anytime you only want the manager contract to interact
    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }
}