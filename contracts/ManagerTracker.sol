pragma solidity ^0.4.24;

import "./Owned.sol";
import "./ManagerData.sol";
import "./SplytManager.sol";

contract ManagerTracker is Owned {
    
    ManagerData public managerData;
    SplytManager public splytManager;

    //allow owner or splytManager
    modifier onlyOwnerOrSplyt() {
        require(owner == msg.sender || address(splytManager) == msg.sender);
        _;
    }

    constructor(address _splytManager) public {
        managerData = new ManagerData();
        splytManager = SplytManager(_splytManager);
    }

    function add(address _managerAddress) public onlyOwnerOrSplyt {
        managerData.add(_managerAddress);
    }

    function getDataContractAddress() public view returns (address) {
       return address(managerData);
    }

    //@desc update data contract address
    function setDataContract(address _dataAddress) onlyOwner public {
       managerData = ManagerData(_dataAddress);
    }


    function disable(address _address) public onlyOwner {
        managerData.disable(_address);
    }  

    function isManager(address _address) public view returns (bool) {
        return managerData.isManager(_address);
    }  

} 