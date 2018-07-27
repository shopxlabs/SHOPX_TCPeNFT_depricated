pragma solidity ^0.4.24;

import "./Arbitration.sol";
import "./ArbitrationData.sol";
import "./Asset.sol";
import "./AssetBase.sol";

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

    function createArbitration(address _assetAddress, string _reason, address _requestedBy) public onlySplytManager {
        Arbitration a = new Arbitration(_assetAddress, _reason, _requestedBy);
        arbitrationData.save(address(a));

        Asset asset = Asset(_assetAddress);
        //change status so no one can purchase during arbitration
        asset.setStatus(AssetBase.AssetStatuses.IN_ARBITRATION);
    }

    //@desc change data contract
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