pragma solidity ^0.4.24;

import "./Owned.sol";
import "./OrderData.sol";
import "./Asset.sol";
import "./SplytManager.sol";
import "./AssetManager.sol";
import "./ArbitrationManager.sol";

contract OrderManager is Owned {
    
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
    modifier onlyPIF(address _assetAddress, uint _qty, uint _tokenAmount) {     
        uint balance = splytManager.getBalance(msg.sender);
        uint totalCost = Asset(_assetAddress).totalCost() * _qty;
        require(_tokenAmount == totalCost && balance >= totalCost);
        _;
    } 

    constructor(address _owner) public {
        orderData = new OrderData();
        splytManager = SplytManager(msg.sender); //splymanager address
        owner = _owner;
    }

    //@desc buyer must pay it in full to create order
    function createOrder(address _assetAddress, uint _qty, uint _tokenAmount) public onlyPIF(_assetAddress, _qty, _tokenAmount) onlyAssetStatus(Asset.Statuses.ACTIVE, _assetAddress) {
        orderData.save(_assetAddress, msg.sender, _qty, _tokenAmount); //save it to the data contract                
        AssetManager(address(splytManager.assetManager)).removeOneInventory(_assetAddress); //update inventory
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
    
}