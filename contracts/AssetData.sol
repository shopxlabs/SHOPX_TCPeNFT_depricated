pragma solidity ^0.4.24;

import "./Owned.sol";

contract AssetData is Owned {
    
    mapping (address => bytes12) public assetIdByAddress;
    mapping (bytes12 => address) public addressByAssetId;
    mapping (uint => address) public addressByIndex;

    uint public assetId; //increments after creating new
    uint public index;

    function save(bytes12 _assetId, address _assetAddress) public onlyOwner returns (bool) {
        assetIdByAddress[_assetAddress] = _assetId;
        addressByAssetId[_assetId] = _assetAddress;
        addressByIndex[index] = _assetAddress;
        index++;
        return true;
    }  
    
    // function getAssetIdByAddress(address _assetAddress) public view returns (bytes12) {
    //     return assetIdByAddress[_assetAddress];
    // }   
     
    // function getAddressByAssetId(bytes12 _assetId) public view returns (address) {
    //     return addressByAssetId[_assetId];
    // }    

    // function getAddressByIndex(uint _index) public view returns (address) {
    //     return addressByIndex[_index];
    // }  

    // function getLength() public view returns (uint) {
    //     return index;
    // }          
}