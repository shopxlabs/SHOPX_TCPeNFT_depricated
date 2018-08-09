pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Events.sol";
import "./Arbitration.sol";
import "./Asset.sol";

// Interface contracts are interface layers to the main contracts which defines
// a function and its input/output parameters. 
// Use in conjuction to real contract's address, you can interact with external
// contract's functions using this interface layer
contract TrackerInterface {
    
    function internalContribute (address _from, address _to, uint _amount) 
        public returns (bool);
        
    function internalRedeemFunds (
        address _listingAddress, 
        address _seller, 
        uint _amount) public returns (bool);
        
    function getBalance(address _wallet) public returns (uint);
    
    function internalArbitrate(string _reason, address _requestedBy) public returns (address);
}

contract Asset is Events, Owned {
    
    enum AssetTypes { NORMAL, FRACTIONAL }
    AssetTypes public assetType;

    enum Statuses { NOT_MINED, ACTIVE, IN_ARBITRATION, EXPIRED, SOLD_OUT, CLOSED, OTHER }
    Statuses public status;
    
    TrackerInterface public tracker;
    address public seller;
    address[] listOfMarketPlaces;
    bytes12 public assetId;
    uint public term;
    uint public amountFunded = 0;
    uint public totalCost;
    uint public expirationDate;
    uint public kickbackAmount;
    bool public isContract = true;
    string public title;
    
    uint initialStakeAmount;
    
    mapping(address => uint) contributions;
    enum report{ SPAM, BROKEN, NOTRECIEVED, NOREASON  }
    address arbitrateAddr = 0x0;
    
    Arbitration arbitration;
    
    uint public inventoryCount;

    //User must have enough funds to call functions
    modifier onlyHasEnoughFunds(address _reporter) {
        uint balance = tracker.getBalance(_reporter);
        require(balance >= initialStakeAmount);
        _;
    }
    
    //only user gets to call certain functions
    modifier onlySeller(address _seller) {
        require(seller == _seller);
        _;
    }

    modifier onlyStatus(Statuses _status) {
         require(status == _status);
         _;
    }

    constructor(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        uint _inventoryCount,
        uint _stakeAmount
        ) public {
            assetId = _assetId;
            term = _term;
            seller = _seller;
            title = _title;
            totalCost = _totalCost;
            expirationDate = _expirationDate;
            kickbackAmount = _mpAmount;
            listOfMarketPlaces.push(_mpAddress);
            tracker = TrackerInterface(msg.sender);
            initialStakeAmount = _stakeAmount;
            inventoryCount = _inventoryCount;

            status = Statuses.ACTIVE;
            assetType =  _term > 0 ? AssetTypes.FRACTIONAL : AssetTypes.NORMAL;
            owner = msg.sender; //assetManager deploys the asset thus the owner
          
    }

    function setStatus(Statuses _status) public onlyOwner {
        status = _status;
    }

    // Getter function. returns a users's total contributions so far for this asset.
    function getMyContributions(address _contributor) public constant returns (uint) {
        return contributions[_contributor];
    }
    
    // Checks to see if asset is open for contributions or not
    // Based on expired or not, and if incoming contribution will overflow the asset or not
    function isOpenForContribution(uint _contributing) public constant returns (bool) {
        if(arbitrateAddr != 0x0)
            return false;
        if (isExpired())
           return false;
        uint willGoOverBoard = _contributing + amountFunded;
        if (willGoOverBoard > totalCost)
            return false;
        if (arbitrateAddr != 0x000)
            return false;
        return true;
    }
    
    // Getter function. returns if asset is fully funded or not
    function isFunded() public constant returns (bool) {
        return amountFunded >= totalCost;
    }
    
    // Getter function. returns if listing is expired or not
    function isExpired() public constant returns (bool) {
        return expirationDate <= now;
    }
    
    // Getter function. returns if asset is fractional or not based on term
    function isFractional() public constant returns (bool) {
        if (term > 0)
            return true;
        return false;
    }
    
    // Handles multi/single contribuitons
    function contribute(address _marketPlace, address _contributor, uint _contributing) public {

        if (!isOpenForContribution(_contributing))
            revert();
        
        bool result;
        uint userBalance = tracker.getBalance(_contributor);
        if (userBalance < _contributing)
            revert();
        listOfMarketPlaces.push(_marketPlace);
        
        if (isFractional()) {
            result = tracker.internalContribute(_contributor, this, _contributing);
            if(result == true)
                addToContributions(_contributor, _contributing);
            releaseFunds();
            
        } else if (_contributing >= totalCost) {
            uint mpGets;
            uint sellerGets;
            (mpGets, sellerGets) = calcDistribution();
            tracker.internalContribute(_contributor, seller, sellerGets);
            addToContributions(_contributor, _contributing);
            if(mpGets > 0)
                for(uint i = 0; i < listOfMarketPlaces.length; i++)
                    tracker.internalContribute(_contributor, listOfMarketPlaces[i], mpGets);
        } else
            revert();
    }
    
    // Calculate how much seller gets after kickbacks taken out
    function calcDistribution() public constant returns (uint, uint) {
        
        uint kickbackWitheld = kickbackAmount / listOfMarketPlaces.length;
        uint sellerGets = totalCost - kickbackWitheld * listOfMarketPlaces.length;
        return (kickbackWitheld, sellerGets);
    }
    
    // Updates this contract's metadata
    function addToContributions(address _contributor, uint _contributing) private {
        amountFunded += _contributing;
        contributions[_contributor] += _contributing;
    }
    
    // This is specifically for fractional sellers
    // It will release funds to seller if listing is fully funded and the listing is expired
    function releaseFunds() public {
        
        if (isFunded()) {
            TrackerInterface trackerContract = TrackerInterface(tracker);
            uint mpGets; 
            uint sellerGets;
            (mpGets, sellerGets) = calcDistribution();
            trackerContract.internalRedeemFunds(this, seller, sellerGets);
            for (uint i = 0; i < listOfMarketPlaces.length; i++)
                trackerContract.internalRedeemFunds(this, listOfMarketPlaces[i], mpGets);
        }
    }
 
    function addOneInventory() public onlyOwner {
        inventoryCount++;
    }  
    //assetManager is the owner
     function removeOneInventory() public onlyOwner {
        inventoryCount--;
        if (inventoryCount == 0) {
            status = Statuses.SOLD_OUT;
        }
    }   

    //assetManager is the owner
     function setInventory(uint _count) public onlyOwner {
        inventoryCount = _count;
    }   

    // report spam assets
    // start refund process
    /*
    function arbitrate(Arbitration.Reasons _reason, address _reporter) public onlyHasEnoughFunds(_reporter) returns (bool) {
        
        // create arbitrate contract and append pause process to all functions.
        arbitration = new Arbitration(this, _reason, _reporter);
        arbitration.setReporterStake(initialStakeAmount);
        
        //reporter stakes the same amount so initial stake amount should be 2x now
        tracker.internalContribute (_reporter, this, initialStakeAmount); 
        emit Success(3, arbitrateAddr);
        return true;        
        
    }
    
    // dispute reported spam
    // only seller can call
    function disputeArbitrationBySeller(address _seller) public onlySeller(_seller) onlyHasEnoughFunds(_seller) returns (bool) {
        
        arbitration.setDisputedStakeBySeller(initialStakeAmount);
        
        //now seller has 2x stake amoount
        //original stake amount + disputed stake amoount = total stake amount by seller
        tracker.internalContribute (_seller, this, initialStakeAmount); 
        emit Success(4, arbitrateAddr);
        return true;        
        
    }
    */    
}