pragma solidity ^0.4.21;

import "./Asset.sol";
import "./Events.sol";


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
    address public satToken;
    address public arbitrator;
    mapping (address => bytes12) assetIdByAddress;
    mapping (bytes32 => address) addressByassetId;
    
    // Events to notify other market places of something
    // Success events gets triggered when a listing is created or a listing is fully funded
    // _code: 1 = listing created, 2 = contributions came in
    // _assetAddress: the asset address for which the code happened
    // event Success(uint _code, address _assetAddress);
    // event Error(uint _code, string _message);


    constructor(uint _version, string _ownedBy, address _satToken, address _arbitratorAddr) public {
        version = _version;
        ownedBy = _ownedBy;
        satToken = _satToken;
        arbitrator = _arbitratorAddr;
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
        uint _mpAmount) 
        public {
            address newAsset = new Asset(_assetId, _term, _seller, _title, _totalCost, _exiprationDate, _mpAddress, _mpAmount);
            assetIdByAddress[newAsset] = _assetId;
            addressByassetId[_assetId] = newAsset;
            emit Success(1, newAsset);
    }

    // Getter function. returns asset contract address given asset UUID
    function getAddressById(bytes12 _listingId) public constant returns (address) {
        return addressByassetId[_listingId];
    }

    // Getter function. returns asset's UUID given asset's contract address
    function getIdByAddress(address _contractAddr) public constant returns (bytes12) {
        return assetIdByAddress[_contractAddr];
    }
    
    // User for single buy to transfer tokens from buyer address to seller address
    function internalContribute(address _from, address _to, uint _amount) public returns (bool) {
        
        if(assetIdByAddress[msg.sender] == "0x0")
            return false;
        TokenInterface tokenContract = TokenInterface(satToken);
        bool result = tokenContract.transferFrom(_from, _to, _amount);
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
        TokenInterface tokenContract = TokenInterface(satToken);
        bool result = tokenContract.transferFrom(_listingAddress, _seller, _amount);
        if(result == true) 
            emit Success(2, msg.sender);
        else 
            emit Error(2, msg.sender, "Could not make transfer happen");
        return result;
    }
    
    function internalArbitrate(string _reason, address _requestedBy) public returns (address) {
        ArbitratorInterface arbitratorContract = ArbitratorInterface(arbitrator);
        return arbitratorContract.createArbitration(_reason, _requestedBy);
    }
    
    // Getter function. returns token contract address
    function getBalance(address _wallet) public returns (uint) {
        TokenInterface tokenContract = TokenInterface(satToken);
        return tokenContract.balanceOf(_wallet);
    }
}