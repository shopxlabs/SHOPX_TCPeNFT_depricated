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
        mapping (bytes12 => bytes12) bytesAttributes; //for future 
        mapping (bytes12 => uint) intAttributes; //for future
        mapping (bytes12 => address) addressAttributes; //for future
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

    function getStatusByOrderId(uint _orderId) public view returns (Statuses) {
        return orders[_orderId].status;    
    }        

    function setBytesAttribute(uint _orderId, bytes12 _attributeKey, bytes12 _attributeValue) public returns (bool) {
        orders[_orderId].bytesAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getBytesAttribute(uint _orderId, bytes12 _attributeKey) public view returns (bytes12) {
        return orders[_orderId].bytesAttributes[_attributeKey];    
    }

    function setIntAttribute(uint _orderId, bytes12 _attributeKey, uint _attributeValue) public returns (bool) {
        orders[_orderId].intAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getIntAttribute(uint _orderId, bytes12 _attributeKey) public view returns (uint) {
        return orders[_orderId].intAttributes[_attributeKey];    
    }           

    function setAddressAttribute(uint _orderId, bytes12 _attributeKey, address _attributeValue) public returns (bool) {
        orders[_orderId].addressAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getAddressAttribute(uint _orderId, bytes12 _attributeKey) public view returns (address) {
        return orders[_orderId].addressAttributes[_attributeKey];    
    }       


}