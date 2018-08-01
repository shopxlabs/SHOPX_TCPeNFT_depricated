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

contract ArbitratorInterface {
    function createArbitration(string _reason, address _requesdedBy) public returns (address);
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

    constructor() public {
    
    }

    // constructor(address _assetManager, address _orderManager, address _arbitrationManager) public {
    //     orderManager = OrderManager(_orderManager);
    //     assetManager = AssetManager(_assetManager);
    //     arbitrationManager = ArbitrationManager(_arbitrationManager);        
    // }
    
    //used to update contracts
    function setAssetManager(address _newAddress) onlyOwner public {
        assetManager = AssetManager(_newAddress);
    }    

    //used to update contracts
    function setOrderManager(address _newAddress) onlyOwner public {
        orderManager = OrderManager(_newAddress);
    } 
    //used to update contracts
    function setArbitrationManager(address _newAddress) onlyOwner public {
        arbitrationManager = ArbitrationManager(_newAddress);
    }      
    //used to update contracts
    function setStake(address _newAddress) onlyOwner public {
        stake = StakeInterface(_newAddress);
    }      

    // User for single buy to transfer tokens from buyer address to seller address
    function internalContribute(address _from, address _to, uint _amount) public returns (bool) {
        bool result = satToken.transferFrom(_from, _to, _amount);
        return result;
    }
    
    // Used for fractional ownership to transfer tokens from user address to listing address
    function internalRedeemFunds(address _listingAddress, address _seller, uint _amount) public returns (bool) {
        
        bool result = satToken.transferFrom(_listingAddress, _seller, _amount);
        return result;
    }

    // Getter function. returns token contract address
    function getBalance(address _wallet) public returns (uint) {
        return satToken.balanceOf(_wallet);
    }


}