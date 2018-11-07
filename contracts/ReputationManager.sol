pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Events.sol";

import "./Reputation.sol";
import "./ReputationData.sol";
import "./SplytManager.sol";

contract ReputationManager is Owned, Events  {
    
    ReputationData public reputationData;
    SplytManager public splytManager;

    //@dev allow owner or splytManager
    modifier onlyOwnerOrSplyt() {
        require(owner == msg.sender || address(splytManager) == msg.sender);
        _;
    }

    //@dev only within 1-5
    modifier onlyValidRange(uint _rating) {
        require( _rating > 0 && _rating < 6);
        _;
    }

    constructor(address _splytManager) public {
        reputationData = new ReputationData();
        splytManager = SplytManager(_splytManager);
    }

    //@dev only create new review when it creates first review
    function createRate(address _wallet, uint _rating) public onlyValidRange(_rating) {

         address reputationAddress = reputationData.reputationByWallet(_wallet);

         if (reputationAddress == address(0)) {
            Reputation reputation = new Reputation(_wallet, _rating, msg.sender);
            reputationData.save(_wallet, address(reputation));
         } else {
            Reputation rep = Reputation(reputationAddress);
            //@if found,update else create new
            bool found = false;
            for (uint i =0; i < rep.getRatesLength(); i++) {
                if (msg.sender == rep.getRaterByIndex(i)) {
                    rep.updateRate(i, _rating);
                    found = true;
                }              
            }
            if (!found) {
                rep.addRate(_rating, msg.sender);
            }
         }

         emit Success(5, reputationAddress);   
    }

    //@dev get review information
    function getRateInfoByWalletAndIndex(address _wallet, uint _index) public view returns (uint, address, uint, address) {

        Reputation rep = Reputation(reputationData.reputationByWallet(_wallet));
        return rep.getRateInfoByIndex(_index);      
    }  

    //@dev get review information
    function getReputationInfoByIndex(uint _index) public view returns (address, uint, uint, address) {

        Reputation rep = Reputation(reputationData.reputationByIndex(_index));
        uint length = rep.getRatesLength();
        uint average = getAverageRatingByWallet(rep.wallet());

        return (rep.wallet(), average, length, address(rep));      
    }  

    //@dev get review information
    function getReputationInfoByWallet(address _wallet) public view returns (address, uint, uint, address) {

        Reputation rep = Reputation(reputationData.reputationByWallet(_wallet));
        uint length = rep.getRatesLength();
        uint average = getAverageRatingByWallet(rep.wallet());

        return (rep.wallet(), average, length, address(rep));      
    }  


    function getReputationsLength() public view returns (uint) {
       return reputationData.index();
    }


    function getDataContractAddress() public view returns (address) {
       return address(reputationData);
    }


    //@dev update data contract address
    function setDataContract(address _reputationData) onlyOwner public {
       reputationData = ReputationData(_reputationData);
    }

    //@dev get asset stat

    function setSplytManager(address _address) public onlyOwnerOrSplyt {
        splytManager = SplytManager(_address);
    }


    function getReputationAddressByWallet(address _wallet) public view returns (address) {
      return reputationData.reputationByWallet(_wallet);
    }  

    //@dev checks if address is authorized write to the data contracts
    function isManager(address _address) public view returns (bool) {
        return splytManager.isManager(_address);
    }
   
    //@dev assume 2 decimals
    function getAverageRatingByWallet(address _wallet) public view returns (uint) {
        address reputationAddress = reputationData.reputationByWallet(_wallet);
        Reputation rep = Reputation(reputationAddress);
        uint totalScore = 0;
        for (uint i =0; i < rep.getRatesLength(); i++) {
            totalScore += rep.getRatingByIndex(i);
        }
       return ((totalScore * 100) / rep.getRatesLength());

    } 
    //@dev get total ratings
    function getTotalRatingByWallet(address _wallet) public view returns (uint) {
        address reputationAddress = reputationData.reputationByWallet(_wallet);
        Reputation rep = Reputation(reputationAddress);
        uint totalScore = 0;
        for (uint i =0; i < rep.getRatesLength(); i++) {
            totalScore += rep.getRatingByIndex(i);
        }
       return totalScore;

    } 
    
   //@dev new manager contract that's going to be replacing this
   //Old manager call this function and proposes the new address
    function transferOwnership(address _newAddress) public onlyOwnerOrSplyt {
        reputationData.transferOwnership(_newAddress);
    }

    //@dev if new data contract is deployed, the creator proposes manager adress then the manager needs to accept
    //The new updated manager contract calls this function
    function acceptOwnership() public onlyOwner {
        reputationData.acceptOwnership();
    }

} 