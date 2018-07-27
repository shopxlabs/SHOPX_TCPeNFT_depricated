pragma solidity ^0.4.24;

import "./Owned.sol";

contract AssetData is Owned {
    
    mapping (address => uint) public assetIdByAddress;
    mapping (uint => address) public addressByAssetId;
                                     
    uint public assetId; //increments after creating new
    address public manager; //address of manager contract

    // only let order manager security
    modifier onlyManager() {
        require(manager == msg.sender);
        _;
    }

    constructor(address _manager, address _owner) public {
        orderManager = _manager;
        owner = _owner;
    }

    function save(address _assetAddress) public onlyManager returns (bool success) {
        assetIdByAddress[_assetAddress] = assetId;
        addressByAssetId[assetId] = _assetAddress;
        assetId++;
        return true;
    }  
    
    function getAssetIdByAddress(address _assetAddress) public view returns (uint) {
        return assetIdByAddress[_assetAddress];
    }    
    function getAddressByAssetId(uint _assetId) public view returns (address) {
        return addressByAssetId[_assetId];
    }    

    //after being deployed set order manager so it only has access to write
    function setOrderManager(address _address) onlyOwner public returns (bool) {
        orderManager = _address;
        return true;
    }  

}