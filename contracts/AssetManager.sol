pragma solidity ^0.4.24;


import "./Owned.sol";
import "./Asset.sol";
import "./AssetData.sol";
import "./SplytManager.sol";

contract AssetManager is Owned {
    
    AssetData public assetData;
    SplytManager public splytManager;


    constructor(address _splytManager) public {
        assetData = new AssetData();
        splytManager = SplytManager(_splytManager);
        owner = msg.sender; 
    }

    //allow owner or splytManager
    modifier onlyOwnerOrSplyt() {
        require(owner == msg.sender || address(splytManager) == msg.sender);
        _;
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
        uint sellersBal = splytManager.getBalance(_seller);
        uint stakeTokens = splytManager.calculateStakeTokens(_totalCost);

    
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

        splytManager.internalContribute(_seller, asset, stakeTokens);
        assetData.save(_assetId, address(asset));
    }

    //@desc update data contract address
    function getAssetInfo(address _assetAddress) public view returns (bytes12, uint, uint){
        Asset asset = Asset(_assetAddress);
        return (asset.assetId(), asset.term(), asset.inventoryCount());
    }

    //@desc update data contract address
    function setDataContract(address _assetData) onlyOwner public {
       assetData = AssetData(_assetData);
    }
   
    //@desc update data contract address
    function setStatus(address _assetAddress, Asset.Statuses _status) onlyOwner public {
        Asset(_assetAddress).setStatus(_status);
    }

    //@desc update data contract address
    function setInventory(address _assetAddress, uint _count) onlyOwner public {
        Asset(_assetAddress).setInventory(_count);
    }


    function removeOneInventory(address _assetAddress) public onlyOwnerOrSplyt {
       Asset(_assetAddress).removeOneInventory();
    }
   

    function setSplytManager(address _address) public onlyOwner {
        splytManager = SplytManager(_address);
    }

    function getAddressById(bytes12 _assetId) public view returns (address) {
      return assetData.getAddressByAssetId(_assetId);
    }
    
    function getIdByAddress(address _assetAddress) public view returns (bytes12) {
      return assetData.getAssetIdByAddress(_assetAddress);
    }    



}