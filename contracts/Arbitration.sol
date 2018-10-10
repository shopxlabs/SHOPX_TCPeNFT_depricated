pragma solidity ^0.4.24;

import './Asset.sol';  //change to interface later

contract Arbitration {
    
    enum Reasons { SPAM, BROKEN, NOTRECIEVED, NOREASON }
    enum Winners { UNDECIDED, REPORTER, SELLER, NEITHER }
    enum Statuses { REPORTED, SELLER_STAKED_2X, REPORTER_STAKED_2X, PENDING_DECISION, RESOLVED, UNRESOLVED }

    bytes12 public arbitrationId;
    address public reporter;
    Reasons public reason;
    
    uint public baseStake;
    uint public reporterStakeTotal;
    uint public sellerStakeTotal;

    Winners public winner;
    Statuses public status;

    address public asset;
    address public arbitrator;


    modifier onlyManager() {
        require(ManagerAbstract(msg.sender).isManager(msg.sender) == true);
        _;
    }

    constructor(bytes12 _arbitrationId, address _assetAddress, Reasons _reason, address _reporter, uint _stakeAmount) public {
        arbitrationId = _arbitrationId;
        reason = _reason;
        reporter = _reporter;
        reporterStakeTotal = _stakeAmount;
        baseStake = _stakeAmount;

        status = Statuses.REPORTED;
        asset = _assetAddress;
        sellerStakeTotal += _stakeAmount;

    }  
    
    //@dev selected arbitrator gets to decide case
    //Arbitrator can select winner only after reporter 2x
    function setWinner(Winners _winner) public onlyManager {
        winner = _winner;
        status = Statuses.RESOLVED;
    }    

    function getWinner() public view returns (Winners) {
        return winner;
    }    


    //@dev set arbitrator so that person resolves this arbitration
    function setArbitrator(address _arbitrator) public onlyManager {
        arbitrator = _arbitrator;
        status = Statuses.PENDING_DECISION;
    } 

    //@dev get arbitrator
    function getArbitrator() public view returns (address) {
       return arbitrator;
    } 

    //@dev seller disputes reporter by staking initial stake amount
    //@dev initial stake is asset contract
    function set2xStakeBySeller() public onlyManager {
        sellerStakeTotal += baseStake; //match reported stake by seller
        status = Statuses.SELLER_STAKED_2X;
        sellerStakeTotal += baseStake;
    }      

    //@dev report puts in 2x stake
    function set2xStakeByReporter() public onlyManager {
        reporterStakeTotal += baseStake;
        //match reported stake by seller
        status = Statuses.REPORTER_STAKED_2X;
        reporterStakeTotal += baseStake;
    }     
    
    function getSeller() public view returns (address) {
        return Asset(asset).seller();
    }  

    function getTotalStake() public view returns (uint) {
        return (sellerStakeTotal + reporterStakeTotal);
    }  
}