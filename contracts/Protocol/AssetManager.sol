// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./Asset.sol";
import "./AssetData.sol";
import "./SplytManager.sol";
import "../Utils/Owned.sol";
import "../Utils/Events.sol";


interface IOracle {
    function getEthUsd() external returns (uint _ethUsdPrice);
}

contract AssetManager is Owned, Events {
    
    AssetData public assetData;
    SplytManager public splytManager;
    IOracle oracleInstance;
    address oracleAddress;
    address payable splytWalletAddress;

    // Temp: test variables
    uint public depositTokensAllocated;
    uint public depositTokensNeeded;
    // End Temp

    //allow owner or splytManager
    modifier onlyOwnerOrSplyt() {
        require(owner == msg.sender || address(splytManager) == msg.sender, "You are not authorized to interact");
        _;
    }

    constructor ( address _splytManager ) public {
        assetData = new AssetData();
        splytManager = SplytManager(_splytManager);
    }

    function createAsset(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string memory _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        uint _inventoryCount) public {

        //calculate stake
        uint sellersBal = splytManager.getBalance(_seller);
        
        uint stakeTokensPerAsset = splytManager.calculateStakeTokens(_totalCost);
        uint stakeTokensTotal = stakeTokensPerAsset * _inventoryCount;

        assert(sellersBal > stakeTokensTotal);

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
            stakeTokensPerAsset
            ); 

        splytManager.internalContribute(_seller, address(asset), stakeTokensTotal);
        assetData.save(_assetId, address(asset));
        emit Success(1, address(asset));
    }

    function getAssetInfoByAssetId(bytes12 _assetId) public view 
    returns (address, bytes12, Asset.Statuses, Asset.AssetTypes, uint, uint, address, uint) {
        Asset asset = Asset(assetData.addressByAssetId(_assetId));
        return (address(asset), asset.assetId(), asset.status(), asset.assetType(), asset.term(), 
        asset.inventoryCount(), asset.seller(), asset.totalCost());
    }

    function getAssetInfoByAddress(address _assetAddress) public view 
    returns (address, bytes12, Asset.Statuses, Asset.AssetTypes, uint, uint, address, uint) {
        Asset asset = Asset(_assetAddress);
        return (address(asset), asset.assetId(), asset.status(), asset.assetType(), asset.term(), 
        asset.inventoryCount(), asset.seller(), asset.totalCost());        
    }

    function getAssetInfoByIndex(uint _index) public view 
    returns (address, bytes12, Asset.Statuses, Asset.AssetTypes, uint, uint, address, uint){
        Asset asset = Asset(assetData.addressByIndex(_index));
        return (address(asset), asset.assetId(), asset.status(), asset.assetType(), asset.term(), 
        asset.inventoryCount(), asset.seller(), asset.totalCost());                   
    }


    function getAssetsLength() public view returns (uint){
        return assetData.index();
    }

    function getDataContractAddress() public view returns (address) {
        return address(assetData);
    }

    function getMarketPlacesLengthByAssetId(bytes12 _assetId) public view returns (uint) {
        Asset asset = Asset(assetData.addressByAssetId(_assetId));          
        return asset.getMarketPlacesLength();
    }
    
    function getMarketPlaceByAssetIdAndIndex(bytes12 _assetId, uint _index) public view returns (address) {
        Asset asset = Asset(assetData.addressByAssetId(_assetId));

        return (asset.listOfMarketPlaces(_index));
    }

    //@dev update data contract address
    function setDataContract(address _assetData)public onlyOwner {
        assetData = AssetData(_assetData);
    }

    //@dev get asset status
    function getType(address _assetAddress) public view returns (Asset.AssetTypes) {
        return Asset(_assetAddress).assetType();
    }

    //@dev get asset status
    function getStatus(address _assetAddress) public view returns (Asset.Statuses) {
        return Asset(_assetAddress).status();
    }

    //@dev add marketplace to asset
    function addMarketPlaceByAssetAddress(address _assetAddress, address _marketPlace) public {
        Asset(_assetAddress).addMarketPlace(_marketPlace);
    }

    //@dev add marketplace to asset
    function addMarketPlaceByAssetId(bytes12 _assetId) public {
        Asset(assetData.addressByAssetId(_assetId)).addMarketPlace(msg.sender);
    }


    //@dev update data contract address
    function setStatus(address _assetAddress, Asset.Statuses _status) public onlyOwnerOrSplyt {
        Asset(_assetAddress).setStatus(_status);
    }

    //@dev update data contract address
    function setInventory(address _assetAddress, uint _count) public onlyOwnerOrSplyt {
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
        return assetData.addressByAssetId(_assetId);
    }
    
    function getIdByAddress(address _assetAddress) public view returns (bytes12) {
        return assetData.assetIdByAddress(_assetAddress);
    }    

    function getAddressByIndex(uint _index) public view returns (address) {
        return assetData.addressByIndex(_index);
    }    

    //@dev checks if address is authorized write to the data contracts
    function isManager(address _address) public view returns (bool) {
        return splytManager.isManager(_address);
    }
   
   //@dev new manager contract that's going to be replacing this
   //Old manager call this function and proposes the new address
    function transferOwnership(address _newAddress) public onlyOwnerOrSplyt {
        assetData.transferOwnership(_newAddress);
    }

    //@dev if new data contract is deployed, the creator proposes manager adress then the manager needs to accept
    //The new updated manager contract calls this function
    function acceptOwnership() public onlyOwner {
        assetData.acceptOwnership();
    }

    function ethToShopx(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string memory _title, 
        uint _totalCost, // $ 100 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        uint _inventoryCount
    ) public payable {
        // get current ether price
        uint ethPrice = oracleInstance.getEthUsd(); // $90.59 / 1 ether
        // msg.value = 0.0565 Eth
        depositTokensAllocated = msg.value * ethPrice;
        uint oneEthToWei = 1000000000000000000;
        depositTokensAllocated = depositTokensAllocated / oneEthToWei;
        depositTokensNeeded = splytManager.calculateStakeTokens(_totalCost * _inventoryCount);


        // // confirm ether sent-in are the same as deposit amount required
        // uint stakeTokensPerAsset = splytManager.calculateStakeTokens(_totalCost * _inventoryCount);
        // uint differenceInCalculations;
        
        // // used to find the variation between 2 values, we use that value to confirm it falls under 10% variation
        // if(ethPrice * msg.value >= stakeTokensPerAsset) {
        //   differenceInCalculations = ethPrice * msg.value  -  stakeTokensPerAsset;
        // } else {
        //   differenceInCalculations = stakeTokensPerAsset  -  ethPrice * msg.value;
        // }
        
        // // confirm ether sent as depost and _totalCost * deposit % are same
        
        // uint itemPriceInUsd = msg.value * ethPrice;
        // // transfer ethers to splyt's wallet address
        splytWalletAddress.transfer(msg.value);
        createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
    }

    function test()public returns(uint) {
        return oracleInstance.getEthUsd();
    }

    function setOracleAddress(address _oracleAddress) public {
        oracleAddress = _oracleAddress;
        oracleInstance = IOracle(oracleAddress);
    }
} 