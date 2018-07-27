pragma solidity ^0.4.24;
import "./Owned.sol";

contract OrderData is Owned {
    
    mapping (address => uint) public orderIdByAddress;
    mapping (uint => address) public addressByOrderId;
                                     
    uint public orderId; //increments after creating new
    address manager; //manager contract address

    function save(address _orderAddress) public returns (bool success) {
        orderIdByAddress[_orderAddress] = orderId;
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
    
    //after being deployed set order manager so it only has access to write
    function setOrderManager(address _address) onlyOwner public returns (bool) {
        orderManager = _address;
        return true;
    }      
}