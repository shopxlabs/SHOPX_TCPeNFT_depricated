// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./Arbitration.sol";
import "./ArbitrationData.sol";
import "./Asset.sol";
import "./SplytManager.sol";
import "../Utils/Owned.sol";
import "../Utils/Events.sol";


contract ArbitrationManager is Owned, Events {

    SplytManager public splytManager;
    ArbitrationData public arbitrationData;
    
    //middlware only arbitrator 
    modifier onlyArbitrator(bytes12 _arbitrationId) {
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);      
        require(Arbitration(arbitrationAddress).arbitrator() == msg.sender, "You aren't the arbitrator");
        _;
    }

    modifier onlyReporter(bytes12 _arbitrationId) {
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);
        require(Arbitration(arbitrationAddress).reporter() == msg.sender, "You aren't the reporter");
        _;
    }
        
    modifier onlySeller(bytes12 _arbitrationId) {
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);
        address assetAddress = Arbitration(arbitrationAddress).asset();
        require(Asset(assetAddress).seller() == msg.sender, "You aren't the seller");
        _;
    }

    modifier onlyStatus(bytes12 _arbitrationId, Arbitration.Statuses _status) {
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);
        require(Arbitration(arbitrationAddress).status() == _status, "Error Status cannot be changed"); 
        _;
    }        

    constructor(address _splytManager) {
        splytManager = SplytManager(_splytManager);
        arbitrationData = new ArbitrationData();
    }

    function createArbitration(bytes12 _arbitrationId, address _assetAddress, Arbitration.Reasons _reason) public {

        Asset asset = Asset(_assetAddress);
        uint stakeAmount = asset.initialStakeAmount(); //get initital stake amount
        
        address reporter = msg.sender;

        Arbitration arbitration = new Arbitration(_arbitrationId, _assetAddress, _reason, reporter, stakeAmount);
        arbitrationData.save(_arbitrationId, address(arbitration));

        //change status so no one can purchase during arbitration
        splytManager.setAssetStatus(_assetAddress, Asset.Statuses.IN_ARBITRATION);
        //set stake for reporter
        splytManager.internalContribute(reporter, address(asset), stakeAmount);
        
        emit Success(3, address(arbitration));
      
    }

    //TODO: write test to see if tokens gets distributed correctly to winner and arbitrator
    function setWinner(bytes12 _arbitrationId, Arbitration.Winners _winner) public
    onlyArbitrator(_arbitrationId) onlyStatus(_arbitrationId, Arbitration.Statuses.PENDING_ARBITRATOR_DECISION) {
        
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);
        Arbitration arbitration = Arbitration(arbitrationAddress);
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
        }
        if (_winner == Arbitration.Winners.SELLER) {
            splytManager.setAssetStatus(assetAddress, Asset.Statuses.ACTIVE);
            splytManager.internalContribute(assetAddress, Asset(assetAddress).seller(), winnerStake);
        }
        splytManager.internalContribute(assetAddress, arbitration.arbitrator(), arbitratorReward); 
    }    

    function getWinner(bytes12 _arbitrationId) public view returns (Arbitration.Winners){
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);           
        return Arbitration(arbitrationAddress).winner();
    }    


    //@dev set arbitrator so that person resolves this arbitration
    function setArbitrator(bytes12 _arbitrationId, address _arbitrator) public
    onlyOwner onlyStatus(_arbitrationId, Arbitration.Statuses.REPORTER_STAKED_2X){
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);   
        Arbitration(arbitrationAddress).setArbitrator(_arbitrator);
    } 

    //@dev get arbitrator
    function getArbitrator(bytes12 _arbitrationId) public view returns (address) {
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);   
        return Arbitration(arbitrationAddress).arbitrator();
    } 

    //@dev get arbitration status
    function getStatus(bytes12 _arbitrationId) public view returns (Arbitration.Statuses) {
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);  
        return Arbitration(arbitrationAddress).status();
    } 


    //@dev get number of arbitrations
    function getArbitrationsLength() public view returns (uint) {
        return arbitrationData.index();
    }

    //@dev  return address or arbitration
    function getAddressById(bytes12 _arbitrationId) public view returns (address) {
        return arbitrationData.addressByArbitrationId(_arbitrationId);
    }

    function getDataContractAddress() public view returns (address) {
        return address(arbitrationData);
    }

    //@dev change data contract
    function setDataContract(address _arbitrationData) public onlyOwner {
        arbitrationData = ArbitrationData(_arbitrationData);
    }
    
    //@dev set splytmanager
    function setSplytManager(address _address) public onlyOwner {
        splytManager = SplytManager(_address);
    }

    function getAddressByArbitrationId(bytes12 _arbitrationId) public view returns (address) {
        return arbitrationData.addressByArbitrationId(_arbitrationId);
    }
    
    function getArbitrationIdByAddress(address _arbitrationAddress) public view returns (bytes12) {
        return arbitrationData.arbitrationIdByAddress(_arbitrationAddress);
    }   

    function getArbitrationByIndex(uint _index) public view returns (address) {
        return arbitrationData.addressByIndex(_index);
    }   

    function getArbitrationInfoByIndex(uint _index) public view 
    returns (bytes12, Arbitration.Reasons, address, Arbitration.Winners, Arbitration.Statuses, address, address, address) {
        Arbitration a = Arbitration(arbitrationData.addressByIndex(_index));
        return (a.arbitrationId(), a.reason(), a.reporter(), a.winner(), a.status(), a.asset(), a.arbitrator(), address(a));
    }   

    function getArbitrationInfoByArbitrationId(bytes12 _arbitrationId) public view 
    returns (bytes12, Arbitration.Reasons, address, Arbitration.Winners, Arbitration.Statuses, address, address, address) {
        Arbitration a = Arbitration(arbitrationData.addressByArbitrationId(_arbitrationId));
        return (a.arbitrationId(), a.reason(), a.reporter(), a.winner(), a.status(), a.asset(), a.arbitrator(), address(a));
    }   

    //@dev seller disputes reporter by staking initial stake amount
    //@dev initial stake is asset contract
    function set2xStakeBySeller(bytes12 _arbitrationId) public 
    onlySeller(_arbitrationId) onlyStatus(_arbitrationId, Arbitration.Statuses.REPORTED){
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);           
        Arbitration arbitration = Arbitration(arbitrationAddress);
        arbitration.set2xStakeBySeller();

        splytManager.internalContribute(arbitration.getSeller(), arbitration.asset(), arbitration.baseStake()); 
        // emit Success(4, address(arbitration)); 
    }      

    //@dev report puts in 2x stake
    function set2xStakeByReporter(bytes12 _arbitrationId) public 
    onlyReporter(_arbitrationId) onlyStatus(_arbitrationId, Arbitration.Statuses.SELLER_STAKED_2X){
        address arbitrationAddress = arbitrationData.addressByArbitrationId(_arbitrationId);   
        Arbitration arbitration = Arbitration(arbitrationAddress);
        arbitration.set2xStakeByReporter();
        splytManager.internalContribute(arbitration.reporter(), arbitration.asset(), arbitration.baseStake()); 
    }

    //@dev checks if address is authorized write to the data contracts
    function isManager(address _address) public view returns (bool) {
        return splytManager.isManager(_address);
    }
}