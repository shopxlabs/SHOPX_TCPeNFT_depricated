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


    constructor(address _splytManager) public {
        assetData = new AssetData();
        splytManager = SplytManager(_splytManager);
        owner = msg.sender; 
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
        uint _inventoryCount) public {

        //calculate stake
        // uint sellersBal = splytManager.getBalance(_seller);
        // uint stakeTokens = stake.calculateStakeTokens(_totalCost);

        uint sellersBal = 0;
        uint stakeTokens = 0;
        
    
        // if(stakeTokens > sellersBal) {
        //     revert();
        // }

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

    function getAddressById(bytes12 _assetId) public view returns (address) {
      return assetData.getAddressByAssetId(_assetId);
    }
    
    function getIdByAddress(address _assetAddress) public view returns (bytes12) {
      return assetData.getAssetIdByAddress(_assetAddress);
    }    



}