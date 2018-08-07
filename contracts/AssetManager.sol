pragma solidity ^0.4.24;


import "./Owned.sol";
import "./Asset.sol";
import "./AssetData.sol";
import "./SplytManager.sol";
import "./Stake.sol";

contract AssetManager is Owned {
    
    AssetData public assetData;
    SplytManager public splytManager;
    Stake public stake;


    constructor(address _owner) public {
        assetData = new AssetData();
        splytManager = SplytManager(msg.sender);
        owner = _owner; 
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
        uint _inventoryCount) public onlyOwner {

        //calculate stake
        uint sellersBal = splytManager.getBalance(_seller);
        uint stakeTokens = stake.calculateStakeTokens(_totalCost);
    
        if(stakeTokens > sellersBal) {
            revert();
        }

         Asset asset = new Asset(
            _assetId, 
            _term, 
            _seller, 
            _title, 
            _totalCost, 
            _expirationDate, 
            _mpAddress, 
            _mpAmount,
            _inventoryCount,
            stakeTokens); 
        assetData.save(_assetId, address(asset));
    }

    //@desc update data contract address
    function setDataContract(address _assetData) onlyOwner public {
       assetData = AssetData(_assetData);
    }
   
    function removeOneInventory(address _assetData) onlyOwner public {
       Asset(_assetData).removeOneInventory();
    }
   

    function setSplytManager(address _address) public onlyOwner {
        splytManager = SplytManager(_address);
    }

    function setStakeLibrary(address _address) public onlyOwner {
        stake = Stake(_address);
    }

    function getAddressByAssetId(bytes12 _assetId) public view returns (address) {
      return assetData.getAddressByAssetId(_assetId);
    }
    
    function getAssetIdByAddress(address _assetAddress) public view returns (bytes12) {
      return assetData.getAssetIdByAddress(_assetAddress);
    }    



}