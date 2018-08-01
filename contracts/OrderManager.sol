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
    

    modifier onlyStatus(Asset.Statuses _status, address _assetAddress) {
        require(Asset.Statuses.ACTIVE == Asset(_assetAddress).status());
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

    function createOrder(bytes12 _orderId, address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public onlyOwner onlyPIF(_assetAddress, _tokenAmount) onlyStatus(Asset.Statuses.ACTIVE, _assetAddress) {
        Order order = new Order(_orderId, _assetAddress, _buyer, _qty, _tokenAmount); //create new order if it passes all the qualifiers
        Asset(_assetAddress).removeOneInventory(); //update inventory 
        orderData.save(_orderId, address(order)); //save it to the data contract
    }

    function getOrderIdByAddress(address _orderAddress) public view returns (bytes12) {
        return orderData.getOrderIdByAddress(_orderAddress);
    }  
    
    function getAddressByOrderId(bytes12 _orderId) public view returns (address) {
        return orderData.getAddressByOrderId(_orderId);
    }       
    
   function setDataContract(address _orderData) onlyOwner public {
       orderData = OrderData(_orderData);
    }
    
}