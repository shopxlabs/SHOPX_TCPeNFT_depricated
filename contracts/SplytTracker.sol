pragma solidity ^0.4.24;

import "./Asset.sol";
import "./Events.sol";

contract StakeInterface {
    function calculateStakeTokens(uint _itemCost) public returns (uint _stakeToken);
}

contract TokenInterface {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function balanceOf(address _wallet) public returns (uint);
}

contract ArbitratorInterface {
    function createArbitration(string _reason, address _requesdedBy) public returns (address);
}

contract SplytTracker is Events {

    uint public version;
    string public ownedBy;
    TokenInterface public satToken;
    address public arbitrator;
    StakeInterface public stake;
    mapping (address => bytes12) public assetIdByAddress;
    mapping (bytes32 => address) public addressByassetId;
    
    // Events to notify other market places of something
    // Success events gets triggered when a listing is created or a listing is fully funded
    // _code: 1 = listing created, 2 = contributions came in
    // _assetAddress: the asset address for which the code happened
    // event Success(uint _code, address _assetAddress);
    // event Error(uint _code, string _message);


    constructor(uint _version, string _ownedBy, address _satToken, address _stake) public {
        version = _version;
        ownedBy = _ownedBy;
        satToken = TokenInterface(_satToken);
        stake = StakeInterface(_stake);
    }

    // Setter functions. creates new asset contract given the parameters
    function createAsset(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _exiprationDate, 
        address _mpAddress, 
        uint _mpAmount,
        Asset.AssetTypes _assetType
        ) 
        public {
            StakeInterface stakeContract = StakeInterface(stake);
            uint sellersBal = getBalance(_seller);
            uint stakeTokens = stakeContract.calculateStakeTokens(_totalCost);
            if(stakeTokens > sellersBal) {
                revert();
            }
            
            address newAsset = new Asset(_assetId, _term, _seller, _title, _totalCost, _exiprationDate, _mpAddress, _mpAmount, _assetType);
            assetIdByAddress[newAsset] = _assetId;
            addressByassetId[_assetId] = newAsset;
            
            internalContribute(_seller, newAsset, stakeTokens);
            
            emit Success(1, newAsset);
    }

    // User for single buy to transfer tokens from buyer address to seller address
    function internalContribute(address _from, address _to, uint _amount) public returns (bool) {
        
        if(assetIdByAddress[msg.sender] == "0x0")
            return false;
        bool result = satToken.transferFrom(_from, _to, _amount);
        if(result == true)
            emit Success(2, msg.sender);
        else 
            emit Error(2, msg.sender, "Could not make transfer happen");
        return result;
    }
    
    // Used for fractional ownership to transfer tokens from user address to listing address
    function internalRedeemFunds(address _listingAddress, address _seller, uint _amount) public returns (bool) {
        
        if(assetIdByAddress[msg.sender] == "0x0") {
            emit Error(1, msg.sender, "Asset contract not in splyt tracker");
            return false;
        }
        bool result = satToken.transferFrom(_listingAddress, _seller, _amount);
        if(result == true) 
            emit Success(2, msg.sender);
        else 
            emit Error(2, msg.sender, "Could not make transfer happen");
        return result;
    }
    
    function internalArbitrate(string _reason, address _requestedBy) public returns (address) {
        ArbitratorInterface arbitratorContract = ArbitratorInterface(arbitrator);
        address arbCont = arbitratorContract.createArbitration(_reason, _requestedBy);
        emit Success(3, _requestedBy);
        return arbCont;
    }
    
    // Getter function. returns token contract address
    function getBalance(address _wallet) public returns (uint) {
        return satToken.balanceOf(_wallet);
    }
}