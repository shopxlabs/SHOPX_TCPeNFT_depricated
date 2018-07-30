pragma solidity ^0.4.24;

import "./Arbitration.sol";
import "./ArbitrationData.sol";
import "./Asset.sol";
import "./AssetBase.sol";

contract ArbitrationManager is Owned {

    ArbitrationData public arbitrationData;
    
    constructor() public {
    
    }

    function createArbitration(address _assetAddress, Arbitration.Reasons _reason, address _requestedBy) public onlyOwner {
        Arbitration a = new Arbitration(_assetAddress, _reason, _requestedBy);
        arbitrationData.save(address(a));

        Asset asset = Asset(_assetAddress);
        //change status so no one can purchase during arbitration
        asset.setStatus(AssetBase.AssetStatuses.IN_ARBITRATION);
    }

/*
    function disputeArbitrationBySeller(address _seller) public onlySeller(_seller) onlyHasEnoughFunds(_seller) returns (bool) {
        
        arbitration.setDisputedStakeBySeller(initialStakeAmount);
        
        //now seller has 2x stake amoount
        //original stake amount + disputed stake amoount = total stake amount by seller
        tracker.internalContribute (_seller, this, initialStakeAmount); 
        emit Success(4, arbitrateAddr);
        return true;        
        
    }  
*/

    //@desc change data contract
    function setDataContract(address _arbitrationData) public {
       arbitrationData = ArbitrationData(_arbitrationData);
    }
    
    function getAddressByArbitrationId(uint _arbitrationId) public view returns (address) {
      return arbitrationData.getAddressByArbitrationId(_arbitrationId);
    }
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (uint) {
      return arbitrationData.getArbitrationIdByAddress(_arbitrationAddress);
    }    
   
}