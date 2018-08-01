pragma solidity ^0.4.24;

import "./Managed.sol";

contract AssetData is Managed {
    
    mapping (address => bytes12) public assetIdByAddress;
    mapping (bytes12 => address) public addressByAssetId;
                                     
    uint public assetId; //increments after creating new
 
    function save(bytes12 _assetId, address _assetAddress) public onlyManager returns (bool) {
        assetIdByAddress[_assetAddress] = _assetId;
        addressByAssetId[_assetId] = _assetAddress;
        return true;
    }  
    
    function getAssetIdByAddress(address _assetAddress) public view returns (bytes12) {
        return assetIdByAddress[_assetAddress];
    }   
     
    function getAddressByAssetId(bytes12 _assetId) public view returns (address) {
        return addressByAssetId[_assetId];
    }    

}