pragma solidity >= 0.5.13;

import "./Owned.sol";
import "./ManagerData.sol";
import "./SplytManager.sol";

//@dev this contract keeps history of all the managers. This contract is used when a contract is owned by a previous manager contract. 
//This contract allows current managers access to write old contracts owned by depracated managers.
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

    //@dev update data contract address
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