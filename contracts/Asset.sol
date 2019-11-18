pragma solidity >= 0.4.24;

import "./Events.sol";

//TODO: use interfaces
import "./Arbitration.sol";
import "./Asset.sol";


contract ManagerAbstract {
    function isManager(address) public returns (bool);
}


contract Asset is Events {
    
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
    string public title;
    
    uint public initialStakeAmount;

    mapping(address => uint) contributions;
    // address arbitrateAddr = 0x0;
    
    address public arbitration;
    
    uint public inventoryCount;

    modifier onlyManager() {
        require(ManagerAbstract(msg.sender).isManager(msg.sender) == true, "You aren't the manager");
        _;
    }

    constructor(bytes12 _assetId, uint _term, address _seller, string memory _title, uint _totalCost, uint _expirationDate, 
      address _mpAddress, uint _mpAmount, uint _inventoryCount, uint _stakeAmount) public {
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

        status = Statuses.ACTIVE;
        assetType = _term > 0 ? AssetTypes.FRACTIONAL : AssetTypes.NORMAL;
    }

    function setStatus(Statuses _status) public onlyManager {
        status = _status;
    }

    // Getter function. returns if asset is fractional or not based on term
    function getMarketPlaceByIndex(uint _index) public view returns (address) {
        return listOfMarketPlaces[_index];
    }   

    function getMarketPlacesLength() public view returns (uint) {
        return listOfMarketPlaces.length;
    }   

    function addMarketPlace(address _marketPlace) public onlyManager {
        listOfMarketPlaces.push(_marketPlace);
    }  

    function addInventory(uint _qty) public onlyManager {
        inventoryCount += _qty;
    }  

    //assetManager is the owner
    function subtractInventory(uint _qty) public onlyManager {
        inventoryCount -= _qty;
        if (inventoryCount == 0)
            status = Statuses.SOLD_OUT;
    }   

    //assetManager is the owner
    function setInventory(uint _count) public onlyManager {
        inventoryCount = _count;
    }  
    
    function isOnlyAffiliate() public view returns (bool) {
        return seller == listOfMarketPlaces[0];
    }

     
}