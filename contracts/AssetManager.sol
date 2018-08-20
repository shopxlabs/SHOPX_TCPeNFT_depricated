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

    //@desc get asset status
    function getType(address _assetAddress) public view returns (Asset.AssetTypes) {
        return Asset(_assetAddress).assetType();
    }

    //@desc get asset status
    function getStatus(address _assetAddress) public view returns (Asset.Statuses) {
        return Asset(_assetAddress).status();
    }

    //@desc update data contract address
    function setStatus(address _assetAddress, Asset.Statuses _status) onlyOwnerOrSplyt public {
        Asset(_assetAddress).setStatus(_status);
    }

    //@desc update data contract address
    function setInventory(address _assetAddress, uint _count) onlyOwnerOrSplyt public {
        Asset(_assetAddress).setInventory(_count);
    }


    function addInventory(address _assetAddress, uint _qty) public onlyOwnerOrSplyt {
       Asset(_assetAddress).addInventory(_qty);
    }

    function subtractInventory(address _assetAddress, uint _qty) public onlyOwnerOrSplyt {
       Asset(_assetAddress).subtractInventory(_qty);
    }
   

    function setSplytManager(address _address) public onlyOwnerOrSplyt {
        splytManager = SplytManager(_address);
    }


    function getAddressById(bytes12 _assetId) public view returns (address) {
      return assetData.getAddressByAssetId(_assetId);
    }
    
    function getIdByAddress(address _assetAddress) public view returns (bytes12) {
      return assetData.getAssetIdByAddress(_assetAddress);
    }    
   
   //@desc new manager contract that's going to be replacing this
   //Old manager call this function and proposes the new address
    function transferOwnership(address _newAddress) public onlyOwnerOrSplyt {
        assetData.transferOwnership(_newAddress);
    }

    //@desc if new data contract is deployed, the creator proposes manager adress then the manager needs to accept
    //The new updated manager contract calls this function
    function acceptOwnership() public onlyOwner {
        assetData.acceptOwnership();
    }

} 