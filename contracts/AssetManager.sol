pragma solidity ^0.4.24;


import "./Owned.sol";
import "./Asset.sol";
import "./AssetData.sol";
import "./AssetBase.sol";

contract AssetManager is Owned {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    AssetData public assetData;
    
    constructor() public {
       assetData = new AssetData();
    }

    function createAsset(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _initialStakeAmount,
        uint _mpAmount,
        AssetBase.AssetTypes _assetType,
        uint _inventoryCount) public onlyOwner {

        Asset asset = new Asset(
            _assetId, 
            _term, 
            _seller, 
            _title, 
            _totalCost, 
            _expirationDate, 
            _mpAddress, 
            _mpAmount,
            _initialStakeAmount,
            _assetType,
            _inventoryCount); 
        assetData.save(address(asset));
    }

    //used if you want to change your data contract
    function setDataContract(address _assetData) public {
       assetData = AssetData(_assetData);
    }
   

    function getAddressByAssetId(uint _assetId) public view returns (address) {
      return assetData.getAddressByAssetId(_assetId);
    }
    
    function getAssetIdByAddress(address _assetAddress) public view returns (uint) {
      return assetData.getAssetIdByAddress(_assetAddress);
    }    

    function acceptDataOwnership() public onlyOwner returns (bool) {
        assetData.acceptOwnership();
        return true;
    }    

}