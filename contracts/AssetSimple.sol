pragma solidity ^0.4.24;

import "./AssetBase.sol";

contract AssetSimple is AssetBase {

    address public seller;
    uint public assetId;
    uint public cost;
    uint inventoryCount;
    
    // modifier onlyAssetStatus(AssetSatus _assetStatus) {
    //     require(assetStatus == _assetStatus);
    //     _;
    // }
    
    constructor(uint _assetId, address _seller, uint _cost, uint _inventoryCount) public {
        assetId = _assetId;
        cost = _cost;
        seller = _seller;
        inventoryCount = _inventoryCount;
    }
    
}