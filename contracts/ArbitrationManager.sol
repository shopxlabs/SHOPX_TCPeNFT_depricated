pragma solidity ^0.4.24;

import "./Arbitration.sol";
import "./ArbitrationData.sol";
import "./Asset.sol";
import "./SplytManager.sol";

contract ArbitrationManager is Owned {

    SplytManager public splytManager;
    ArbitrationData public arbitrationData;
    
    constructor() public {
    
    }

    function createArbitration(Arbitration.Reasons _reason, address _reporter, address _assetAddress) public onlyOwner {
        
        uint stakeAmount; //calcualte stake amount
        Arbitration a = new Arbitration(_reason, _reporter, stakeAmount, _assetAddress, splytManager);
        arbitrationData.save(address(a));

        Asset asset = Asset(_assetAddress);
        //change status so no one can purchase during arbitration
        asset.setStatus(Asset.Statuses.IN_ARBITRATION);
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
    
    //@desc set splytmanager
    function setSplytManager(address _address) public {
       splytManager = SplytManager(_address);
    }

    function getAddressByArbitrationId(uint _arbitrationId) public view returns (address) {
      return arbitrationData.getAddressByArbitrationId(_arbitrationId);
    }
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (uint) {
      return arbitrationData.getArbitrationIdByAddress(_arbitrationAddress);
    }    
   
}