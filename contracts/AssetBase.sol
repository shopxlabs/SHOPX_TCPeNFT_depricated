pragma solidity ^0.4.24;

contract AssetBase {
    
    enum AssetTypes { NORMAL, FRACTIONAL }
    AssetTypes public assetType;

    enum AssetStatuses { ACTIVE, IN_ARBITRATION, EXPIRED, CLOSED, OTHER }
    AssetStatuses public assetStatus;
    

    modifier onlyAssetStatus(AssetSatus _assetStatus) {
         require(assetStatus == _assetStatus);
         _;
    }
    
    
}