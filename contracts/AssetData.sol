pragma solidity >= 0.5.13;

import "./Owned.sol";

contract AssetData is Owned {
    
    mapping (address => bytes12) public assetIdByAddress;
    mapping (bytes12 => address) public addressByAssetId;
    mapping (uint => address) public addressByIndex;

    uint public index;

    //TODO: add modifier to only let new 
    function save(bytes12 _assetId, address _assetAddress) public onlyOwner returns (bool) {
        assetIdByAddress[_assetAddress] = _assetId;
        addressByAssetId[_assetId] = _assetAddress;
        addressByIndex[index] = _assetAddress;
        index++;
        return true;
    }  
          
}