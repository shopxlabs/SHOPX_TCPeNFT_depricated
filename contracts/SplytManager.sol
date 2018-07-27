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


    constructor(address _assetManager, address _orderManager, address _arbitrationManager) public {
        owner = msg.sender;
        orderManager = OrderManager(_orderManager);
        assetManager = AssetManager(_assetManager);
        arbitrationManager = ArbitrationManager(_arbitrationManager);
    }
    
    function updateAssetManager(address _newAddress) onlyOwner public {
        assetManager = AssetManager(_newAddress);
    }    

    function updateOrderManager(address _newAddress) onlyOwner public {
        orderManager = OrderManager(_newAddress);
    }  

    function updateArbitrationManager(address _newAddress) onlyOwner public {
        assetManager = ArbitrationManager(_newAddress);
    }      
}