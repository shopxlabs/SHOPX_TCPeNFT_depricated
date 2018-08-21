pragma solidity ^0.4.24;

contract ManagerHistory {
    
    mapping (address => bool) public approvedManagers;


    constructor() public {
        approvedManagers[msg.sender] = true;   
    }

    modifier onlyApprovedManagers() {
        require(approvedManagers[msg.sender] == true);
        _;
    }

    function addManager(address _manager) public onlyApprovedManagers {
        approvedManagers[_manager] = true;
    }  
    
    function disableManager(address _manager) public onlyApprovedManagers {
        approvedManagers[_manager] = false;
    }  

    function isApprovedManager(address _mgr) public view returns (bool) {
        return approvedManagers[_mgr];
    }  
    
}