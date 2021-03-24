// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;


//TODO: use interfaces instead after we plan out what functions should be exposed to this contract.
import "./Asset.sol";
import "./AssetManager.sol";
import "./ArbitrationManager.sol";
import "./OrderManager.sol";
import "./ManagerTracker.sol";
import "./ReputationManager.sol";
import "./Stake.sol";
import "../Token/ShopxToken.sol";
import "../Utils/Events.sol";
import "../Utils/Owned.sol";
// END TODO

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
    ShopxToken public shopxToken;
    address public arbitrator;
    Stake public stake;
    
    AssetManager public assetManager;
    OrderManager public orderManager;
    ArbitrationManager public arbitrationManager;
    ReputationManager public reputationManager;
    ManagerTracker public managerTracker;



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

    //@dev set all contracts it's interacting with
    constructor(address _tokenAddress, address _stakeAddress) {
        shopxToken = ShopxToken(_tokenAddress);
        stake = Stake(_stakeAddress);      
    }

    //@dev sets all the managers at once
    function setManagers(address _assetManager, address _orderManager, address _arbitrationManager) public onlyOwner {
        assetManager = AssetManager(_assetManager);
        orderManager = OrderManager(_orderManager);   
        arbitrationManager = ArbitrationManager(_arbitrationManager);     

        //add the managers to give rights to write
        managerTracker.add(_assetManager);   
        managerTracker.add(_orderManager);       
        managerTracker.add(_arbitrationManager);                            
    }        

    //@dev tracks all the managers deployed
    function setManagerTracker(address _newAddress) public onlyOwner {
        managerTracker = ManagerTracker(_newAddress);
    }    

    //@dev used to update contracts
    function setAssetManager(address _newAddress) public onlyOwner {
        assetManager = AssetManager(_newAddress);
        managerTracker.add(_newAddress);
    }    

    //@dev used to update contracts
    function setOrderManager(address _newAddress) public onlyOwner {
        orderManager = OrderManager(_newAddress);
        managerTracker.add(_newAddress);
    } 
    //@dev used to update contracts
    function setArbitrationManager(address _newAddress) public onlyOwner {
        arbitrationManager = ArbitrationManager(_newAddress);
        managerTracker.add(_newAddress);
    }      
 
    //@dev used to update contracts
    function setReputationManager(address _newAddress) public onlyOwner {
        reputationManager = ReputationManager(_newAddress);
        managerTracker.add(_newAddress);
    }      

    function setTokenContract(address _newAddress) public onlyOwner {
        shopxToken = ShopxToken(_newAddress);
    }      

    function setStakeContract(address _newAddress) public onlyOwner {
        stake = Stake(_newAddress);
    } 

    //@dev User for single buy to transfer tokens from buyer address to seller address
    function internalContribute(address _from, address _to, uint _amount) public onlyManagers returns (bool) {
        bool result = shopxToken.transferFrom(_from, _to, _amount);
        return result;
    }
    
    // @dev Used for fractional ownership to transfer tokens from user address to listing address
    function internalRedeemFunds(address _listingAddress, address _seller, uint _amount) public onlyManagers returns (bool) {
        
        bool result = shopxToken.transferFrom(_listingAddress, _seller, _amount);
        return result;
    }

    //@dev Getter function. returns token contract address
    function getBalance(address _wallet) public view returns (uint) {
        return shopxToken.balanceOf(_wallet);
    }

    //@dev calculate stake
    function calculateStakeTokens(uint _amount) public view returns (uint) {
        return stake.calculateStakeTokens(_amount); 
    }

    function subtractInventory(address _assetAddress, uint _qty) public onlyManagers {
        assetManager.subtractInventory(_assetAddress, _qty); 
    }    

    //@dev used to update    
    function setAssetStatus(address _assetAddress, Asset.Statuses _status) public onlyManagers {
        assetManager.setStatus(_assetAddress, _status);
    }   

    //@dev used to update    
    function addInventory(address _assetAddress, uint _quantity) public onlyManagers {
        assetManager.addInventory(_assetAddress, _quantity);
    }    

   function addMarketPlace(address _assetAddress, address _marketPlace) public onlyManagers {
        assetManager.addMarketPlaceByAssetAddress(_assetAddress, _marketPlace);        
    }    


    //@dev used to update    
    function getManagerTrackerAddress() public view returns (address) {
        return address(managerTracker);
    }    

    function isManager(address _address) public view returns (bool) {
        return managerTracker.isManager(_address);
    }

}