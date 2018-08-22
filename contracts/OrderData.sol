pragma solidity ^0.4.24;

import "./Owned.sol";

contract OrderData is Owned {

    //Per conversation, we decided to use struct data structure for storing orders instead of individual contracts for gas savings
    struct Order {
        uint version;
        uint orderId;
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

    // mapping (address => uint) public orderIdByAddress;
    mapping (uint => Order) public orders;                                    
    mapping (address => uint) public fractionalOrders;  //will have asset address if it's a fractional asset

    uint public orderId; //increments after creating new

    constructor() public {
        owner = msg.sender; //orderManager address
    }

    function save(address _asset, address _buyer, uint _quantity, uint _paidAmount) public onlyOwner returns (uint) {
        orders[orderId] = Order(version, orderId, _asset, _buyer, _quantity, _paidAmount, Statuses.PIF, Reasons.NA, 0);
        orderId++;
        return orderId;
    }      

    function setStatus(uint _orderId, Statuses _status) public onlyOwner returns (bool) {
        orders[_orderId].status  = _status;
        return true;
    }  

    function getStatus(uint _orderId) public view returns (Statuses) {
        return orders[_orderId].status;
    }   

    function getPaidAmount(uint _orderId) public view returns (uint) {
        return orders[_orderId].paidAmount;
    } 

    function getAssetAddress(uint _orderId) public view returns (address) {
        return orders[_orderId].asset;
    }   

    function getQuantity(uint _orderId) public view returns (uint) {
        return orders[_orderId].quantity;
    }   

    function getTotalContributions(uint _orderId) public view returns (uint) {
        return orders[_orderId].totalContributions;
    }   

    //create new fractioinal order
    function saveFractional(address _asset, address _contributor, uint _amount, Statuses _status) public onlyOwner returns (uint) {
        orders[orderId].version = version;
        orders[orderId].asset = _asset;
        orders[orderId].status = _status;    
        orders[orderId].contributors[_contributor] += _amount;
        orders[orderId].totalContributions += _amount;
        fractionalOrders[_asset] = orderId;

        orderId++;
    }   

    function updateFractional(uint _orderId, address _contributor, uint _amount, Statuses _status) public onlyOwner returns (uint) {

        orders[_orderId].contributors[_contributor] += _amount;
        orders[_orderId].totalContributions += _amount;
        orders[_orderId].status = _status;    
    }   


    function getFractionalOrderIdByAsset(address _assetAddress) public view returns (uint) {
        return fractionalOrders[_assetAddress];
    }   

    function getMyContributions(uint _orderId, address _contributor) public view returns (uint) {
        return orders[_orderId].contributors[_contributor];
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

    // function setStatusByOrderId(uint _orderId, Statuses _status) public onlyOwner {
    //     orders[_orderId].status = _status;
    // }        

    // function getStatusByOrderId(uint _orderId) public view returns (Statuses) {
    //     return orders[_orderId].status;    
    // }        

    function setBytesAttribute(uint _orderId, bytes12 _attributeKey, bytes12 _attributeValue) public onlyOwner returns (bool) {
        orders[_orderId].bytesAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getBytesAttribute(uint _orderId, bytes12 _attributeKey) public view returns (bytes12) {
        return orders[_orderId].bytesAttributes[_attributeKey];    
    }

    function setIntAttribute(uint _orderId, bytes12 _attributeKey, uint _attributeValue) public onlyOwner returns (bool) {
        orders[_orderId].intAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getIntAttribute(uint _orderId, bytes12 _attributeKey) public view returns (uint) {
        return orders[_orderId].intAttributes[_attributeKey];    
    }           

    function setAddressAttribute(uint _orderId, bytes12 _attributeKey, address _attributeValue) public onlyOwner returns (bool) {
        orders[_orderId].addressAttributes[_attributeKey] = _attributeValue;
        return true;
    }  

    function getAddressAttribute(uint _orderId, bytes12 _attributeKey) public view returns (address) {
        return orders[_orderId].addressAttributes[_attributeKey];    
    }       

}