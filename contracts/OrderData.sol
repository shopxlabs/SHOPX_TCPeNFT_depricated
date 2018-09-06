pragma solidity ^0.4.24;

import "./Owned.sol";

contract OrderData is Owned {

    //Per conversation, we decided to use struct data structure for storing orders instead of individual contracts for gas savings
    //This means this data file cannot be updated.
    struct Order {
        uint version;
        bytes12 orderId;
        address asset;
        address buyer;
        uint quantity;
        uint paidAmount;
        Statuses status;        
        
        Reasons reason;
        uint totalContributions;
        mapping (address => uint) contributors; //for fractional contributors

        mapping (bytes12 => bytes12) bytesAttributes; //for future 
        mapping (bytes12 => uint) intAttributes; //for future
        mapping (bytes12 => address) addressAttributes; //for future
    }
    
    enum Statuses { NA, PIF, CLOSED, REQUESTED_REFUND, REFUNDED, CONTRIBUTIONS_OPEN, CONTRIBUTIONS_FULFILLED, OTHER }
    enum Reasons { NA, DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }

    uint public version = 1;

    mapping (bytes12 => Order) public orders;                                    
    mapping (address => bytes12) public fractionalOrders;  //will have asset address if it's a fractional asset
    mapping (uint =>  bytes12) public orderIdByIndex;

    uint public index;
    //TODO: add modifier t only let new
    function save(bytes12 _orderId, address _asset, address _buyer, uint _quantity, uint _paidAmount) public onlyOwner returns (bool) {
        orders[_orderId] = Order(version, _orderId, _asset, _buyer, _quantity, _paidAmount, Statuses.PIF, Reasons.NA, 0);
        orderIdByIndex[index] = _orderId;
        index++;
        return true;
    }      

    function setStatus(bytes12 _orderId, Statuses _status) public onlyOwner returns (bool) {
        orders[_orderId].status  = _status;
        return true;
    }  

    function getStatus(bytes12 _orderId) public view returns (Statuses) {
        return orders[_orderId].status;
    }   

    function getPaidAmount(bytes12 _orderId) public view returns (uint) {
        return orders[_orderId].paidAmount;
    } 

    function getAssetAddress(bytes12 _orderId) public view returns (address) {
        return orders[_orderId].asset;
    }   

    function getQuantity(bytes12 _orderId) public view returns (uint) {
        return orders[_orderId].quantity;
    }   

    function getTotalContributions(bytes12 _orderId) public view returns (uint) {
        return orders[_orderId].totalContributions;
    }   

    //create new fractioinal order
    function saveFractional(bytes12 _orderId, address _asset, address _contributor, uint _amount, Statuses _status) public onlyOwner returns (uint) {
        orders[_orderId].version = version;
        orders[_orderId].asset = _asset;
        orders[_orderId].status = _status;    
        orders[_orderId].contributors[_contributor] += _amount;
        orders[_orderId].totalContributions += _amount;
        fractionalOrders[_asset] = _orderId;

    }   

    function updateFractional(bytes12 _orderId, address _contributor, uint _amount, Statuses _status) public onlyOwner returns (uint) {

        orders[_orderId].contributors[_contributor] += _amount;
        orders[_orderId].totalContributions += _amount;
        orders[_orderId].status = _status;    
    }   


    function getFractionalOrderIdByAsset(address _assetAddress) public view returns (bytes12) {
        return fractionalOrders[_assetAddress];
    }   

    function getMyContributions(bytes12 _orderId, address _contributor) public view returns (uint) {
        return orders[_orderId].contributors[_contributor];
    }
    

    function getBuyer(bytes12 _orderId) public view returns (address) {
        return orders[_orderId].buyer;
    }   

    function getAsset(bytes12 _orderId) public view returns (address) {
        return orders[_orderId].asset;
    }   

    //@dev same as index
    function getOrderByOrderId(bytes12 _orderId) public view returns (uint, bytes12, address, address, uint, uint, Statuses) {
    
        return (
            orders[_orderId].version,    
            orders[_orderId].orderId,
            orders[_orderId].asset,    
            orders[_orderId].buyer,
            orders[_orderId].quantity,
            orders[_orderId].paidAmount,
            orders[_orderId].status);
    }           

    function setBytesAttribute(bytes12 _orderId, bytes12 _attributeKey, bytes12 _attributeValue) public onlyOwner returns (bool) {
        orders[_orderId].bytesAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getBytesAttribute(bytes12 _orderId, bytes12 _attributeKey) public view returns (bytes12) {
        return orders[_orderId].bytesAttributes[_attributeKey];    
    }

    function setIntAttribute(bytes12 _orderId, bytes12 _attributeKey, uint _attributeValue) public onlyOwner returns (bool) {
        orders[_orderId].intAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getIntAttribute(bytes12 _orderId, bytes12 _attributeKey) public view returns (uint) {
        return orders[_orderId].intAttributes[_attributeKey];    
    }           

    function setAddressAttribute(bytes12 _orderId, bytes12 _attributeKey, address _attributeValue) public onlyOwner returns (bool) {
        orders[_orderId].addressAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getAddressAttribute(bytes12 _orderId, bytes12 _attributeKey) public view returns (address) {
        return orders[_orderId].addressAttributes[_attributeKey];    
    }       

}