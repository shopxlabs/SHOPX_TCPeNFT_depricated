pragma solidity ^0.4.24;
import "./Owned.sol";

import "./Managed.sol";

contract OrderData is Managed {

    
    mapping (address => bytes12) public orderIdByAddress;
    mapping (bytes12 => address) public addressByOrderId;
                                     
    uint public orderId; //increments after creating new
 
    function save(bytes12 _orderId, address _orderAddress) public onlyManager returns (bool) {
        addressByOrderId[_orderId] = _orderAddress;
        orderIdByAddress[_orderAddress] = _orderId;
        return true;
    }  
    
    function getOrderIdByAddress(address _orderAddress) public view returns (bytes12) {
        return orderIdByAddress[_orderAddress];
    }    
    
    function getAddressByOrderId(bytes12 _orderId) public view returns (address) {
        return addressByOrderId[_orderId];
    }      
    
}