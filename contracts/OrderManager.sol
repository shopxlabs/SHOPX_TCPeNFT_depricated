pragma solidity ^0.4.24;

import "./Order.sol";
import "./OrderData.sol";

contract OrderManager {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    OrderData public orderData;
    address public splytManagerAddress;
    
    modifier onlySplytManager() {
        require(msg.sender == splytManagerAddress);
        _;
    }
    
    
    constructor(address _splytManagerAddress) public {
       splytManagerAddress = _splytManagerAddress;
    }

    function createOrder(address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public onlySplytManager {
        Order order = new Order(_assetAddress, _buyer, _qty, _tokenAmount);
        orderData.save(address(order));
    }

    function getOrderIdByAddress(address _orderAddress) public view returns (uint) {
        return orderData.getOrderIdByAddress(_orderAddress);
    }  
    
    function getAddressByOrderId(uint _orderId) public view returns (address) {
        return orderData.getAddressByOrderId(_orderId);
    }       
    
   function updateDataContract(address _orderData) public {
       orderData = OrderData(_orderData);
    }
    
}