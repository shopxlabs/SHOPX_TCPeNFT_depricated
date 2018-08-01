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
    

    modifier onlyAssetActive(address _assetAddress) {
        require(Asset.Statuses.ACTIVE == Asset(_assetAddress).status());
        _;
    }    
    //@desc if buyer commits full amount of the price
    modifier onlyPIF(address _assetAddress, uint _tokenAmount) {
        Asset tmp = Asset(_assetAddress);
        require(_tokenAmount == tmp.totalCost());
        _;
    } 

    constructor() public {
      orderData = new OrderData();
    }

    function createOrder(address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public onlyOwner onlyAssetActive(_assetAddress) {
        Order order = new Order(_assetAddress, _buyer, _qty, _tokenAmount);
        orderData.save(address(order));
    }

    function getOrderIdByAddress(address _orderAddress) public view returns (uint) {
        return orderData.getOrderIdByAddress(_orderAddress);
    }  
    
    function getAddressByOrderId(uint _orderId) public view returns (address) {
        return orderData.getAddressByOrderId(_orderId);
    }       
    
   function setDataContract(address _orderData) onlyOwner public {
       orderData = OrderData(_orderData);
    }
    
}