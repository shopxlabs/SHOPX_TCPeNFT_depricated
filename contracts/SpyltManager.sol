pragma solidity ^0.4.24;

import "./AssetManager.sol";
import "./OrderManager.sol";
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

contract SplytManager is Events {

    uint public version;
    string public ownedBy;
    TokenInterface public satToken;
    address public arbitrator;
    StakeInterface public stake;
    
    AssetManager public assetManager;
    OrderManager public orderManager;
    address public admin;
    
    modifier onlyAdmin() {
        require(admin == msg.sender);
        _;
    }
    
    // Events to notify other market places of something
    // Success events gets triggered when a listing is created or a listing is fully funded
    // _code: 1 = listing created, 2 = contributions came in
    // _assetAddress: the asset address for which the code happened
    // event Success(uint _code, address _assetAddress);
    // event Error(uint _code, string _message);


    constructor(address _assetManager, address _orderManager) public {
        orderManager = OrderManager(_orderManager);
        assetManager = AssetManager(_assetManager);
        admin = msg.sender;
    }
    
    function updateAssetManager(address _newAssetManager) onlyAdmin public {
        assetManager = AssetManager(_newAssetManager);
    }    
    function updateOrderManager(address _newAssetManager) onlyAdmin public {
        assetManager = AssetManager(_newAssetManager);
    }  
}