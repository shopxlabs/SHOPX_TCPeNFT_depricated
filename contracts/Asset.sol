pragma solidity ^0.4.24;

import "./Events.sol";
import "./Arbitration.sol";
import "./Asset.sol";
import "./Owned.sol";

// TODO: use interface instead of importing whole contracts after later sprints
contract Asset is Events, Owned {
    
    enum AssetTypes { NORMAL, FRACTIONAL }
    AssetTypes public assetType;

    enum Statuses { NOT_MINED, ACTIVE, IN_ARBITRATION, EXPIRED, SOLD_OUT, CLOSED, OTHER }
    Statuses public status;
    
    address public seller;
    address[] public listOfMarketPlaces;
    bytes12 public assetId;
    uint public term;
    uint public amountFunded = 0;
    uint public totalCost;
    uint public expirationDate;
    uint public kickbackAmount;
    bool public isContract = true;
    string public title;
    
    uint public initialStakeAmount;

    address public creator;

    mapping(address => uint) contributions;
    // address arbitrateAddr = 0x0;
    
    address arbitration;
    
    uint public inventoryCount;

    constructor(
        bytes12 _assetId, 
        uint _term, 
        address _seller, 
        string _title, 
        uint _totalCost, 
        uint _expirationDate, 
        address _mpAddress, 
        uint _mpAmount,
        uint _inventoryCount,
        uint _stakeAmount,
        address _authorizer
        ) public {
            assetId = _assetId;
            term = _term;
            seller = _seller;
            title = _title;
            totalCost = _totalCost;
            expirationDate = _expirationDate;
            kickbackAmount = _mpAmount;
            listOfMarketPlaces.push(_mpAddress);
            initialStakeAmount = _stakeAmount;
            inventoryCount = _inventoryCount;
            owner = msg.sender;

            status = Statuses.ACTIVE;
            assetType =  _term > 0 ? AssetTypes.FRACTIONAL : AssetTypes.NORMAL;
            authorizer = AuthorizerInterface(_authorizer);
    }

    function setStatus(Statuses _status) public onlyAuthorized {
        status = _status;
    }

    // Getter function. returns if asset is fractional or not based on term
    function getMarketPlaceByIndex(uint _index) public view returns (address) {
        return listOfMarketPlaces[_index];
    }   

    function getMarketPlacesLength() public view returns (uint) {
        return listOfMarketPlaces.length;
    }   
  
    function addInventory(uint _qty) public onlyAuthorized {
        inventoryCount += _qty;
    }  

    //assetManager is the owner
     function subtractInventory(uint _qty) public onlyAuthorized {
        inventoryCount -=  _qty;
        if (inventoryCount == 0) {
            status = Statuses.SOLD_OUT;
        }
    }   

    //assetManager is the owner
     function setInventory(uint _count) public onlyAuthorized {
        inventoryCount = _count;
    }   

     
}