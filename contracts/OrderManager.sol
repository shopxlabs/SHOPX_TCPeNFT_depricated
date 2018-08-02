pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Order.sol";
import "./OrderData.sol";
import "./Asset.sol";

contract OrderManager is Owned {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    OrderData public orderData;
    address public splytManagerAddress;

    //@desc middleware to check for certain asset statuses to continue
    modifier onlyAssetStatus(Asset.Statuses _status, address _assetAddress) {
        require(_status == Asset(_assetAddress).status());
        _;
    }  

    //@desc middleware to check for certain order statuses to continue
    modifier onlyOrderStatus(Order.Statuses _status, address _orderAddress) {
        require(_status == Order(_orderAddress).status());
        _;
    }    

    //@desc if buyer commits full amount of the price
    modifier onlyPIF(address _assetAddress, uint _tokenAmount) {
        require(_tokenAmount == Asset(_assetAddress).totalCost());
        _;
    } 

    constructor(address _orderData) public {
      orderData = OrderData(_orderData);
    }

    //@desc buyer must pay it in full to create order
    function createOrder(bytes12 _orderId, address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public onlyOwner onlyPIF(_assetAddress, _tokenAmount) onlyAssetStatus(Asset.Statuses.ACTIVE, _assetAddress) {
        Order order = new Order(_orderId, _assetAddress, _buyer, _qty, _tokenAmount); //create new order if it passes all the qualifiers
        Asset(_assetAddress).removeOneInventory(); //update inventory 
        orderData.save(_orderId, address(order)); //save it to the data contract
    }

    function requestRefund(address _orderAddress) public onlyOwner onlyOrderStatus(Order.Statuses.PIF, _orderAddress) {
        Order(_orderAddress).requestRefund();
    }
    
    function approveRefund(address _orderAddress) public onlyOwner onlyOrderStatus(Order.Statuses.REQUESTED_REFUND, _orderAddress) {   
        Order(_orderAddress).approveRefund();
    }
 
    
   function setDataContract(address _orderData) public onlyOwner{
       orderData = OrderData(_orderData);
    }
    
}