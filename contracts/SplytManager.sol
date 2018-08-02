pragma solidity ^0.4.24;

import "./AssetManager.sol";
import "./OrderManager.sol";
import "./ArbitrationManager.sol";

import "./Events.sol";
import "./Owned.sol";

contract StakeInterface {
    function calculateStakeTokens(uint _itemCost) public returns (uint _stakeToken);
}

contract TokenInterface {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function balanceOf(address _wallet) public returns (uint);
}

contract SplytManager is Events, Owned {

    uint public version;
    string public ownedBy;
    TokenInterface public satToken;
    address public arbitrator;
    StakeInterface public stake;
    
    AssetManager public assetManager;
    OrderManager public orderManager;
    ArbitrationManager public arbitrationManager;
    
    // Events to notify other market places of something
    // Success events gets triggered when a listing is created or a listing is fully funded
    // _code: 1 = listing created, 2 = contributions came in
    // _assetAddress: the asset address for which the code happened
    // event Success(uint _code, address _assetAddress);
    // event Error(uint _code, string _message);

    //@desc set all contracts it's interacting with
    constructor(address _assetManager, address _orderManager, address _arbitrationManager, address _token, address _stake) public {
        orderManager = OrderManager(_orderManager);
        assetManager = AssetManager(_assetManager);
        arbitrationManager = ArbitrationManager(_arbitrationManager);    
        satToken = TokenInterface(_token);
        stake = StakeInterface(_stake);            
    }

    //@desc sets all the managers at once
    function setManagers(address _assetManager, address _orderManager, address _arbitrationManager) public onlyOwner {
        assetManager = AssetManager(_assetManager);
        orderManager = OrderManager(_orderManager);   
        arbitrationManager = ArbitrationManager(_arbitrationManager);             
    }        

    //@desc used to update contracts
    function setAssetManager(address _newAddress) public onlyOwner {
        assetManager = AssetManager(_newAddress);
    }    

    //TODO: add security
    //@desc used to update contracts
    function setOrderManager(address _newAddress) public onlyOwner {
        orderManager = OrderManager(_newAddress);
    } 
    //@desc used to update contracts
    function setArbitrationManager(address _newAddress) public onlyOwner {
        arbitrationManager = ArbitrationManager(_newAddress);
    }      
 
    //@desc User for single buy to transfer tokens from buyer address to seller address
    //TODO: add security
    function internalContribute(address _from, address _to, uint _amount) public returns (bool) {
        bool result = satToken.transferFrom(_from, _to, _amount);
        return result;
    }
    
    // @desc Used for fractional ownership to transfer tokens from user address to listing address
    // TODO: add security
    function internalRedeemFunds(address _listingAddress, address _seller, uint _amount) public returns (bool) {
        
        bool result = satToken.transferFrom(_listingAddress, _seller, _amount);
        return result;
    }

    //@desc Getter function. returns token contract address
    function getBalance(address _wallet) public returns (uint) {
        return satToken.balanceOf(_wallet);
    }


}