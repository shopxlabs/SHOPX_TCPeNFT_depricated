pragma solidity ^0.4.24;
import "./Owned.sol";

import "./Managed.sol";

contract OrderData is Managed {

    
    mapping (address => uint) public orderIdByAddress;
    mapping (uint => address) public addressByOrderId;
                                     
    uint public orderId; //increments after creating new
 
    function save(address _orderAddress) public onlyManager returns (bool success) {
        addressByOrderId[orderId] = _orderAddress;
        orderId++;
        return true;
    }  
    
    function getOrderIdByAddress(address _orderAddress) public view returns (uint) {
        return orderIdByAddress[_orderAddress];
    }    
    
    function getAddressByOrderId(uint _orderId) public view returns (address) {
        return addressByOrderId[_orderId];
    }      
    
}