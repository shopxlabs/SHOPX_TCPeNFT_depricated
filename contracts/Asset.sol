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

contract Asset {

    address public tracker;
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
    mapping(address => uint) contributions;
    enum report{ SPAM, BROKEN, NOTRECIEVED, NOREASON  }
    address arbitrateAddr = 0x0;

    constructor(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount) public {
            assetId = _assetId;
            term = _term;
            seller = _seller;
            title = _title;
            totalCost = _totalCost;
            expirationDate = _expirationDate;
            kickbackAmount = _mpAmount;
            listOfMarketPlaces.push(_mpAddress);
            tracker = msg.sender;
    }

    function getAssetConfig() public constant returns(
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
        TrackerInterface trackerContract = TrackerInterface(tracker);
        uint userBalance = trackerContract.getBalance(_contributor);
        if (userBalance < _contributing)
            revert();
        listOfMarketPlaces.push(_marketPlace);
        
        if (isFractional()) {
            result = trackerContract.internalContribute(_contributor, this, _contributing);
            if(result == true)
                addToContributions(_contributor, _contributing);
            releaseFunds();
            
        } else if (_contributing >= totalCost) {
            uint mpGets;
            uint sellerGets;
            (mpGets, sellerGets) = calcDistribution();
            trackerContract.internalContribute(_contributor, seller, sellerGets);
            addToContributions(_contributor, _contributing);
            if(mpGets > 0)
                for(uint i = 0; i < listOfMarketPlaces.length; i++)
                    trackerContract.internalContribute(_contributor, listOfMarketPlaces[i], mpGets);
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
    
    // report spam assets
    // start refund process
    function arbitrate(string _reason, address _requestedBy) public returns (bool) {
        
        // create arbitrate contract and append pause process to all functions.
        TrackerInterface trackerContract = TrackerInterface(tracker);
        arbitrateAddr = trackerContract.internalArbitrate(_reason, _requestedBy);
    }
}