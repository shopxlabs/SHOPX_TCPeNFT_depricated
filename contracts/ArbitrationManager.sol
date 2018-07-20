pragma solidity ^0.4.24;

import "./Arbitration.sol";
import "./ArbitrationData.sol";

contract ArbitrationManager {
    
    address public splytManager;
    ArbitrationData public arbitrationData;
    
    modifier onlySplytManager() {
        require(msg.sender == splytManager);
        _;
    }
    
    constructor(address _splytManager) public {
       splytManager = _splytManager;
    }

    function createArbitration(string _reason, address _requestedBy) public onlySplytManager {
        Arbitration a = new Arbitration(_reason, _requestedBy);
        arbitrationData.save(address(a));
    }

    function updateDataContract(address _arbitrationData) public {
       arbitrationData = ArbitrationData(_arbitrationData);
    }
    
    function getAddressByArbitrationId(uint _arbitrationId) public view returns (address) {
      return arbitrationData.getAddressByArbitrationId(_arbitrationId);
    }
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (uint) {
      return arbitrationData.getArbitrationIdByAddress(_arbitrationAddress);
    }    
}