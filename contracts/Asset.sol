pragma solidity ^0.4.24;

import "./Events.sol";

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

contract Asset is Events {

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
    uint totalStakeAmount;
    
    mapping(address => uint) contributions;
    enum report{ SPAM, BROKEN, NOTRECIEVED, NOREASON  }
    address arbitrateAddr = 0x0;

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

    
    constructor(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        uint _stakeAmount) public {
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
            totalStakeAmount = _stakeAmount;
            
    }

    function getAssetConfig() public view returns(
        bytes32, 
        uint, 
        address, 
        uint, 
        string, 
        bool, 
        bool, 
        uint, 
        uint, 
        address, 
        uint) {
        return (
            assetId, 
            term, 
            seller, 
            amountFunded, 
            title, 
            isFunded(), 
            isExpired(), 
            totalCost, 
            expirationDate, 
            listOfMarketPlaces[0], 
            kickbackAmount);
    }

    // Getter function. returns a users's total contributions so far for this asset.
    function getMyContributions(address _contributor) public view returns (uint) {
        return contributions[_contributor];
    }
    
    // Checks to see if asset is open for contributions or not
    // Based on expired or not, and if incoming contribution will overflow the asset or not
    function isOpenForContribution(uint _contributing) public view returns (bool) {
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
    function isFunded() public view returns (bool) {
        return amountFunded >= totalCost;
    }
    
    // Getter function. returns if listing is expired or not
    function isExpired() public view returns (bool) {
        return expirationDate <= now;
    }
    
    // Getter function. returns if asset is fractional or not based on term
    function isFractional() public view returns (bool) {
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
    function calcDistribution() public view returns (uint, uint) {
        
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
    
    // report spam assets
    // start refund process
    function arbitrate(string _reason, address _reporter) public  onlyHasEnoughFunds(_reporter) returns (bool) {
        
        // create arbitrate contract and append pause process to all functions.
        arbitrateAddr = tracker.internalArbitrate(_reason, _reporter);
        //report stakes the same amount so inital stake amount should be 2x now
        tracker.internalContribute (_reporter, this, initialStakeAmount); 
        totalStakeAmount+=initialStakeAmount; //double take amount
        emit Success(3, arbitrateAddr);
        return true;        
        
    }
    
    // dispute reported spam
    // only seller can call
    function disputeReportedSpam(address _seller) public onlySeller(_seller) onlyHasEnoughFunds(_seller) returns (bool) {
        
        tracker.internalContribute (_seller, this, initialStakeAmount); 
        totalStakeAmount+=initialStakeAmount; //double take amount
        emit Success(4, arbitrateAddr);
        return true;        
        
    }    
}