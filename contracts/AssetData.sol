pragma solidity ^0.4.24;

contract AssetData  {
    
    mapping (address => uint) public assetIdByAddress;
    mapping (uint => address) public addressByAssetId;
                                     
    uint public assetId; //increments after creating new
 
    function save(address _assetAddress) public returns (bool success) {
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
    
}