pragma solidity ^0.4.24;

import "./Order.sol";
import "./OrderData.sol";
import "./AssetBase.sol";

contract OrderManager {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    OrderData public orderData;
    address public splytManagerAddress;
    
    modifier onlySplytManager() {
        require(msg.sender == splytManagerAddress);
        _;
    }

    modifier onlyAssetActive(address _assetAddress) {
        require(AssetBase.AssetStatuses.ACTIVE == Asset(_assetAddress).assetStatus());
        _;
    }    
    //@desc if buyer commits full amount of the price
    modifier onlyPIF(address _assetAddress, uint _tokenAmount) {
        Asset tmp = Asset(_assetAddress);
        require(_tokenAmount == tmp.totalCost());
        _;
    } 

    constructor(address _splytManagerAddress) public {
       splytManagerAddress = _splytManagerAddress;
    }

    function createOrder(address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public onlySplytManager onlyAssetActive(_assetAddress) {
        Order order = new Order(_assetAddress, _buyer, _qty, _tokenAmount);
        orderData.save(address(order));
    }

    function getOrderIdByAddress(address _orderAddress) public view returns (uint) {
        return orderData.getOrderIdByAddress(_orderAddress);
    }  
    
    function getAddressByOrderId(uint _orderId) public view returns (address) {
        return orderData.getAddressByOrderId(_orderId);
    }       
    
   function setDataContract(address _orderData) public {
       orderData = OrderData(_orderData);
    }
    
}