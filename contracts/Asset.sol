pragma solidity ^0.4.24;

import "./AssetBase.sol";

contract Asset is AssetBase {
    
    address public tracker;
    address public seller;
    address[] listOfMarketPlaces;
    bytes12 public assetId;
    uint public term; //in days
    uint public amountFunded = 0;
    uint public totalCost;
    uint public expirationDate;
    uint public kickbackAmount;
    bool public isContract = true;
    string public title;
    mapping(address => uint) contributions;
    enum report{ SPAM, BROKEN, NOTRECIEVED, NOREASON  }
    address arbitrateAddr = 0x0;

    uint inventoryCount;
    
    // modifier onlyAssetStatus(AssetSatus _assetStatus) {
    //     require(assetStatus == _assetStatus);
    //     _;
    // }
    

//    constructor(uint _assetId, address _seller, uint _cost, uint _inventoryCount) public {
//        assetId = _assetId;
//        cost = _cost;
//        seller = _seller;
//      inventoryCount = _inventoryCount;
//    }


    constructor(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        AssetTypes _assetType,
        uint _inventoryCount) public {
            assetId = _assetId;
            term = _term;
            seller = _seller;
            title = _title;
            totalCost = _totalCost;
            expirationDate = _expirationDate;
            kickbackAmount = _mpAmount;
            listOfMarketPlaces.push(_mpAddress);
            assetType = _assetType;
            assetStatus = AssetStatuses.ACTIVE;
            inventoryCount = _inventoryCount;
    }
 
    function setStatus(AssetStatuses _status) public {
        assetStatus = _status;
    }
}