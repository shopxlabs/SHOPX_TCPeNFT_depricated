pragma solidity ^0.4.24;

import "./AssetManager.sol";
import "./OrderManager.sol";
import "./ArbitrationManager.sol";

import "./Events.sol";
import "./Owned.sol";

import "./SatToken.sol";
import "./Stake.sol";
import "./Asset.sol";


// contract StakeInterface {
//     function calculateStakeTokens(uint _itemCost) public returns (uint _stakeToken);
// }

// contract TokenInterface {
//     function transferFrom(address _from, address _to, uint _value) public returns (bool);
//     function balanceOf(address _wallet) public returns (uint);
// }

contract SplytManager is Events, Owned {

    uint public version;
    string public ownedBy;
    SatToken public satToken;
    address public arbitrator;
    Stake public stake;
    
    AssetManager public assetManager;
    OrderManager public orderManager;
    ArbitrationManager public arbitrationManager;

    //only these managers are allowed to call these functions
    modifier onlyManagers() {
        require(msg.sender == address(orderManager) || msg.sender == address(assetManager) || msg.sender == address(arbitrationManager));
        _;
    }

    // Events to notify other market places of something
    // Success events gets triggered when a listing is created or a listing is fully funded
    // _code: 1 = listing created, 2 = contributions came in
    // _assetAddress: the asset address for which the code happened
    // event Success(uint _code, address _assetAddress);
    // event Error(uint _code, string _message);

    //@desc set all contracts it's interacting with
    constructor(address _tokenAddress, address _stakeAddress) public {
    // constructor(address _assetManager, address _orderManager, address _arbitrationManager, address _token, address _stake) public {
        // orderManager = new OrderManager(msg.sender);
        // assetManager = new AssetManager(msg.sender);
        // arbitrationManager = new ArbitrationManager(msg.sender);    
        owner = msg.sender; //the wallet used to deploy these contracts
        satToken = SatToken(_tokenAddress);
        stake = Stake(_stakeAddress);            
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
    function internalContribute(address _from, address _to, uint _amount) public onlyManagers returns (bool) {
        bool result = satToken.transferFrom(_from, _to, _amount);
        return result;
    }
    
    // @desc Used for fractional ownership to transfer tokens from user address to listing address
    // TODO: add security
    function internalRedeemFunds(address _listingAddress, address _seller, uint _amount) public onlyManagers returns (bool) {
        
        bool result = satToken.transferFrom(_listingAddress, _seller, _amount);
        return result;
    }

    //@desc Getter function. returns token contract address
    function getBalance(address _wallet) public view returns (uint) {
        return satToken.balanceOf(_wallet);
    }

    //@desc calculate stake
    function calculateStakeTokens(uint _amount) public view returns (uint) {
        return stake.calculateStakeTokens(_amount); 
    }

    function subtractInventory(address _assetAddress, uint _qty) public {
        assetManager.subtractInventory(_assetAddress, _qty); 
    }    

    //@desc used to update    
    function setAssetStatus(address _assetAddress, Asset.Statuses _status) public onlyManagers {
        assetManager.setStatus(_assetAddress, _status);
    }    


}