pragma solidity ^0.4.24;

import "./AssetSimple.sol";
import "./AssetData.sol";

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

    function createAsset(address _seller, uint _cost, uint _inventoryCount) public onlySplytManager {
        AssetSimple asset = new AssetSimple(assetData.assetId(), _seller, _cost, _inventoryCount);
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