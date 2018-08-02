pragma solidity ^0.4.24;

import "./Managed.sol";

contract OrderData is Managed {

    struct Order {
        uint version;
        uint orderId;
        address asset;
        address buyer;
        uint quantity;
        uint paidAmount;
        Statuses status;
    }
    
    enum Statuses { PIF, CLOSED, REQUESTED_REFUND, REFUNDED, OTHER }

    uint public version = 1;

    // mapping (address => uint) public orderIdByAddress;
    mapping (uint => Order) public orders;
                                     
    uint public orderId; //increments after creating new

    function save(address _asset, address _buyer, uint _quantity, uint _paidAmount) public onlyManager returns (bool) {
        orders[orderId] = Order(version, orderId, _asset, _buyer, _quantity, _paidAmount, Statuses.PIF);
        orderId++;
        return true;
    }  

    function updateStatus(uint _orderId, Statuses _status) public onlyManager returns (bool) {
        orders[_orderId].status  = _status;
        return true;
    }  
    
    function getBuyer(uint _orderId) public view returns (address) {
        return orders[_orderId].buyer;
    }   

    function getAsset(uint _orderId) public view returns (address) {
        return orders[_orderId].asset;
    }   

    function getOrderByOrderId(uint _orderId) public view returns (uint, uint, address, address, uint, uint, Statuses) {
    
        return (
            orders[_orderId].version,    
            orders[_orderId].orderId,
            orders[_orderId].asset,    
            orders[_orderId].buyer,
            orders[_orderId].quantity,
            orders[_orderId].paidAmount,
            orders[_orderId].status);
    }        
    
}