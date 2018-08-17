pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Arbitration.sol";
import "./ArbitrationData.sol";
import "./Asset.sol";
import "./SplytManager.sol";

contract ArbitrationManager is Owned {

    SplytManager public splytManager;
    ArbitrationData public arbitrationData;
    
    //middlware only arbitrator 
    modifier onlyArbitrator(address _arbitrationAddress) {
        require(Arbitration(_arbitrationAddress).arbitrator() == msg.sender);
        _;
    }

    modifier onlyReporter(address _arbitrationAddress) {
        require(Arbitration(_arbitrationAddress).reporter() == msg.sender);        
        _;
    }
        
    modifier onlySeller(address _arbitrationAddress) {
        address assetAddress = Arbitration(_arbitrationAddress).asset();
        require(Asset(assetAddress).seller() == msg.sender);        
        _;
    }
        

    constructor(address _splytManager) public {
        splytManager = SplytManager(_splytManager);
        arbitrationData = new ArbitrationData();
        owner = msg.sender;
    }

    function createArbitration(address _assetAddress, bytes12 _arbitrationId, Arbitration.Reasons _reason) public {

        Asset asset = Asset(_assetAddress);
        uint stakeAmount = asset.initialStakeAmount(); //get initital stake amount
        
        address reporter = msg.sender;

        Arbitration arbitration = new Arbitration(_assetAddress, _arbitrationId, _reason, reporter, stakeAmount);
        arbitrationData.save(_arbitrationId, address(arbitration));

        //change status so no one can purchase during arbitration
        splytManager.setAssetStatus(_assetAddress, Asset.Statuses.IN_ARBITRATION);
        //set stake for reporter
        splytManager.internalContribute(reporter, asset, stakeAmount);
      
    }

    //TODO: write test to see if tokens gets distributed correctly to winner and arbitrator
    function setWinner(address _arbitrationAddress, Arbitration.Winners _winner) onlyArbitrator public {
        
        Arbitration arbitration = Arbitration(_arbitrationAddress);
        address assetAddress = arbitration.asset();
        
        arbitration.setWinner(_winner);
        //TODO: rule:
        //winner gets 75% of the stakes
        //arbitrator gets the 25% stake 
        uint winnerStake = (arbitration.getTotalStake() * 75) / 100;
        uint arbitratorReward = (arbitration.getTotalStake() * 25) / 100;

        if (_winner == Arbitration.Winners.REPORTER) {
            splytManager.setAssetStatus(assetAddress, Asset.Statuses.CLOSED);
            splytManager.internalContribute(assetAddress, arbitration.reporter(), winnerStake);
             //TODO: gives the stakes to reporter
        }
        if (_winner == Arbitration.Winners.SELLER) {
            splytManager.setAssetStatus(assetAddress, Asset.Statuses.ACTIVE);
            splytManager.internalContribute(assetAddress, Asset(assetAddress).seller(), winnerStake);
        }
        splytManager.internalContribute(assetAddress, arbitration.arbitrator(), arbitratorReward); 
    }    

    function getWinner(address _arbitrationAddress) public view returns (Arbitration.Winners){
        
        return Arbitration(_arbitrationAddress).winner();
    }    


    //@desc set arbitrator so that person resolves this arbitration
    function setArbitrator(address _arbitrationAddress, address _arbitrator) public onlyOwner {
        Arbitration(_arbitrationAddress).setArbitrator(_arbitrator);
    } 

    //@desc get arbitrator
    function getArbitrator(address _arbitrationAddress) public view returns (address) {
       return Arbitration(_arbitrationAddress).arbitrator();
    } 

    //@desc get arbitration status
    function getStatus(address _arbitrationAddress) public view returns (Arbitration.Statuses) {
       return Arbitration(_arbitrationAddress).status();
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

    //@desc get number of arbitrations
    function getArbitrationsLength() public view returns (uint) {
       return arbitrationData.arbitrationIndex();
    }

    //@desc  return address or arbitration
    function getAddressById(bytes12 _arbitrationId) public view returns (address) {
       return arbitrationData.getAddressByArbitrationId(_arbitrationId);
    }

    //@desc change data contract
    function setDataContract(address _arbitrationData) public onlyOwner {
       arbitrationData = ArbitrationData(_arbitrationData);
    }
    
    //@desc set splytmanager
    function setSplytManager(address _address) public onlyOwner {
       splytManager = SplytManager(_address);
    }

    function getAddressByArbitrationId(bytes12 _arbitrationId) public view returns (address) {
      return arbitrationData.getAddressByArbitrationId(_arbitrationId);
    }
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (bytes12) {
      return arbitrationData.getArbitrationIdByAddress(_arbitrationAddress);
    }   

    //@desc seller disputes reporter by staking initial stake amount
    //@desc initial stake is asset contract
    function set2xStakeBySeller(address _arbitrationAddress) public onlySeller(_arbitrationAddress) {
        Arbitration arbitration = Arbitration(_arbitrationAddress);
        arbitration.set2xStakeBySeller();

        splytManager.internalContribute(arbitration.getSeller(), arbitration.asset(), arbitration.baseStake()); 
        // emit Success(4, address(arbitration)); 
    }      

    //@desc report puts in 2x stake
    function set2xStakeByReporter(address _arbitrationAddress) public onlyReporter(_arbitrationAddress) {
        Arbitration arbitration = Arbitration(_arbitrationAddress);
        arbitration.set2xStakeByReporter();
        splytManager.internalContribute(arbitration.reporter(), arbitration.asset(), arbitration.baseStake()); 
    }
    //@desc if new data contract is deployed, the creator proposes manager adress then the manager needs to accept
    function acceptOwnership() public onlyOwner {
        arbitrationData.acceptOwnership();
    }

}