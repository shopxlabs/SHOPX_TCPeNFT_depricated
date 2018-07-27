pragma solidity ^0.4.24;

import "./Asset.sol";
import "./AssetData.sol";
import "./AssetBase.sol";

contract AssetManager {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    address public splytManager;
    AssetData public assetData;
    
    modifier onlySplytManager() {
        require(msg.sender == splytManager);
        _;
    }
    
    constructor(address _splytManager) public {
       splytManager = _splytManager;
    }

    function createAsset(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        AssetBase.AssetTypes _assetType,
        uint _inventoryCount) public onlySplytManager {

        Asset asset = new Asset(
            _assetId, 
            _term, 
            _seller, 
            _title, 
            _totalCost, 
            _expirationDate, 
            _mpAddress, 
            _mpAmount,
            _assetType,
            _inventoryCount); 
        assetData.save(address(asset));
    }

    function updateDataContract(address _assetData) public {
       assetData = AssetData(_assetData);
    }
    
    function getAddressByAssetId(uint _assetId) public view returns (address) {
      return assetData.getAddressByAssetId(_assetId);
    }
    
    function getAssetIdByAddress(address _assetAddress) public view returns (uint) {
      return assetData.getAssetIdByAddress(_assetAddress);
    }    
}