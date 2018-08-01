pragma solidity ^0.4.24;

import './Asset.sol';  //change to interface later
import './SplytManager.sol';  //change to interface later

contract Arbitration {
    
    enum Reasons { SPAM, BROKEN, NOTRECIEVED, NOREASON }
    enum Winners { UNDECIDED, REPORTER, SELLER  }
    enum Statuses { REPORTED, SELLER_STAKED_2X, REPORTER_STAKED_2X, RESOLVED, UNRESOLVED }

    address public reporter;
    Reasons public reason;
    
    uint public baseStake;
    uint public reporterStakeTotal;
    uint public sellerStakeTotal;
    address public arbitrator;
    
    Winners public winner;
    Statuses public status;

    Asset public asset;
    SplytManager public splytManager;

    modifier onlyArbitrator() {
        require(arbitrator == msg.sender);
        _;
    }

    modifier onlySeller() {
        require(msg.sender == asset.seller());
        _;
    }

    modifier onlyReporter() {
        require(msg.sender == reporter);
        _;
    }

     constructor(Reasons _reason, address _reporter, uint _stakeAmount, address _assetAddress, address _splytManagerAddress) public {
        reason = _reason;
        reporter = _reporter;
        reporterStakeTotal = _stakeAmount;
        baseStake = _stakeAmount;

        status = Statuses.REPORTED;
        asset = Asset(_assetAddress);
        splytManager= SplytManager(_splytManagerAddress);
    }  
    
    //@desc selected arbitrator gets to decide case
    function setWinner(Winners _winner) public onlyArbitrator() {
        winner = _winner;
        status = Statuses.RESOLVED;
        if (winner == Winners.REPORTER) {
            asset.setStatus(Asset.Statuses.CLOSED);
             //TODO: gives the stakes to reporter
        }
        if (winner == Winners.SELLER) {
            asset.setStatus(Asset.Statuses.ACTIVE);
             //TODO: gives the stakes to seller
        }
    }    

    function getWinner() public view returns (Winners) {
        return winner;
    }    


    //@desc set arbitrator so that person resolves this arbitration
    function setArbitrator(address _arbitrator) public {
        arbitrator = _arbitrator;
    } 

    //@desc get arbitrator
    function getArbitrator() public view returns (address) {
       return arbitrator;
    } 

    //@desc seller disputes reporter by staking initial stake amount
    //@desc initial stake is asset contract
    function set2xStakeBySeller() public onlySeller {
        sellerStakeTotal += baseStake; //match reported stake by seller
        status = Statuses.SELLER_STAKED_2X;
        splytManager.internalContribute (asset.seller(), this, baseStake); 
        // emit Success(4, address(arbitration)); 
    }      

    //@desc report puts in 2x stake
    function set2xStakeByReporter() public onlyReporter {
        reporterStakeTotal += baseStake;
        //match reported stake by seller
        status = Statuses.REPORTER_STAKED_2X;
        splytManager.internalContribute (reporter, this, baseStake); 
        // emit Success(4, address(arbitration)); 
    }       
}