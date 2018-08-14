pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Events.sol";
import "./OrderData.sol";
import "./Asset.sol";
import "./SplytManager.sol";
import "./AssetManager.sol";
import "./ArbitrationManager.sol";

contract OrderManager is Owned, Events {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Statuses { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }

    OrderData public orderData;
    SplytManager public splytManager;

    modifier onlyBuyer(uint _orderId) {
        address buyer = orderData.getBuyer(_orderId);  
        require(buyer == msg.sender);
        _;
    }
    
    modifier onlySeller(uint _orderId) {
        address seller = Asset(orderData.getAsset(_orderId)).seller();          
        require(seller == msg.sender);
        _;
    }

    //@desc middleware to check for certain asset statuses to continue
    modifier onlyAssetStatus(Asset.Statuses _status, address _assetAddress) {
        require(_status == Asset(_assetAddress).status());
        _;
    }  

    //@desc middleware to check for certain order statuses to continue
    modifier onlyOrderStatus(uint _orderId, OrderData.Statuses _status) {
        require(_status == orderData.getStatusByOrderId(_orderId));
        _;
    }    

    //@desc if buyer sends total amount
    // modifier onlyOrderRequestQualifies(address _assetAddress, uint _qty, uint _tokenAmount) {     
    //     uint buyerBalance = splytManager.getBalance(msg.sender);
    //     uint totalCost = Asset(_assetAddress).totalCost() * _qty;
    //     uint qty = Asset(_assetAddress).inventoryCount();
    //     require(_tokenAmount >=totalCost && buyerBalance >= totalCost && _qty <= qty);
    //     _;
    // } 

    constructor(address _splytManager) public {
        orderData = new OrderData();
        splytManager = SplytManager(_splytManager); //splytManager address
        owner = msg.sender;
    }

    //@desc buyer must pay it in full to create order
    // To succcessfully purchase an asset, buy must purchase the whole amount times the quantity.
    // The asset must be in 'ACTIVE' status.    
    function createOrder(address _assetAddress, uint _qty, uint _tokenAmount) public onlyAssetStatus(Asset.Statuses.ACTIVE, _assetAddress)  returns (bool) {

        uint buyerBalance = splytManager.getBalance(msg.sender);
        uint totalCost = Asset(_assetAddress).totalCost() * _qty;
        uint qty = Asset(_assetAddress).inventoryCount();
        if (_tokenAmount < totalCost || buyerBalance < totalCost || _qty > qty) {
            revert();
        }


        uint mpGets; //marketplaces commission
        uint sellerGets;

        Asset asset = Asset(_assetAddress);
        (mpGets, sellerGets) = calcDistribution(asset.totalCost(), asset.getMarketPlacesLength(), asset.kickbackAmount());
        splytManager.internalContribute(msg.sender, asset.seller(), sellerGets);
        
        //distribute commission to all the market places
        if(mpGets > 0) {
            for(uint i = 0; i < asset.getMarketPlacesLength(); i++) {
                splytManager.internalContribute(msg.sender, asset.getMarketPlaceByIndex(i), mpGets);
            }
        }

        orderData.save(_assetAddress, msg.sender, _qty, _tokenAmount); //save it to the data contract                
        splytManager.subtractInventory(_assetAddress, _qty); //update inventory
    //     emit NewOrder(200, orderId);
    //     return orderId;
        return true;
    }

    function calcDistribution(uint _totalCost, uint _length, uint _kickbackAmount) public pure returns (uint, uint) {
        // Asset asset = Asset(_assetAddress);
        // uint length = asset.getMarketPlacesLength();

        uint kickbackWitheld = _kickbackAmount / _length;
        uint sellerGets = _totalCost - kickbackWitheld * _length;
        return (kickbackWitheld, sellerGets);
    }


    function approveRefund(uint _orderId) public onlySeller(_orderId) {
        orderData.updateStatus(_orderId, OrderData.Statuses.REFUNDED); //save it to the data contract                 
    }
    
    function requestRefund(uint _orderId) public onlyBuyer(_orderId) {
        orderData.updateStatus(_orderId, OrderData.Statuses.REQUESTED_REFUND); //save it to the data contract        
        //TODO: refund  token process        
    }    

    function setSplytManager(address _address) public onlyOwner {
        splytManager = SplytManager(_address);
    }

    function setDataContract(address _orderData) public onlyOwner {
       orderData = OrderData(_orderData);
    }

    function getOrderByOrderId(uint _orderId) public view returns (uint, uint, address, address, uint, uint, OrderData.Statuses) {
      return orderData.getOrderByOrderId(_orderId);
    }    

    function getDataVersion() public view returns (uint) {
      return orderData.version();
    }    


    function getOrdersLength() public view returns (uint) {
      return orderData.orderId();
    }       
    
}