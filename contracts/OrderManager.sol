pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Events.sol";
import "./OrderData.sol";
import "./Asset.sol";
import "./SplytManager.sol";
import "./AssetManager.sol";
import "./ArbitrationManager.sol";

contract OrderManager is Owned, Events {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Statuses { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }

    OrderData public orderData;
    SplytManager public splytManager;

    modifier onlyBuyer(bytes12 _orderId) {
        address buyer = orderData.getBuyer(_orderId);  
        require(buyer == msg.sender);
        _;
    }
    
    modifier onlySeller(bytes12 _orderId) {
        address seller = Asset(orderData.getAsset(_orderId)).seller();          
        require(seller == msg.sender);
        _;
    }

    //@dev middleware to check for certain asset statuses to continue
    modifier onlyAssetStatus(Asset.Statuses _status, address _assetAddress) {
        require(_status == Asset(_assetAddress).status());
        _;
    }  

    //@dev middleware to check for certain order statuses to continue
    modifier onlyOrderStatus(bytes12 _orderId, OrderData.Statuses _status) {
        require(_status == orderData.getStatus(_orderId));
        _;
    }    

    //@dev middleware to bind functions that should be called by fractional
    modifier onlyFractionalAsset(address _assetAddress) {
        require(Asset.AssetTypes.FRACTIONAL == Asset(_assetAddress).assetType());
        _;
    }    

    //@dev if buyer sends total amount
    // modifier onlyOrderRequestQualifies(address _assetAddress, uint _qty, uint _tokenAmount) {     
    //     uint buyerBalance = splytManager.getBalance(msg.sender);
    //     uint totalCost = Asset(_assetAddress).totalCost() * _qty;
    //     uint qty = Asset(_assetAddress).inventoryCount();
    //     require(_tokenAmount >=totalCost && buyerBalance >= totalCost && _qty <= qty);
    //     _;
    // } 

    constructor(address _splytManager) public {
        orderData = new OrderData();
        splytManager = SplytManager(_splytManager); //splytManager address
    }

    //@dev buyer must pay it in full to create order
    // To succcessfully purchase an asset, buy must purchase the whole amount times the quantity.
    // The asset must be in 'ACTIVE' status.    
    function purchase(bytes12 _orderId, address _assetAddress, uint _qty, uint _tokenAmount) public onlyAssetStatus(Asset.Statuses.ACTIVE, _assetAddress) returns (bool) {

        Asset asset = Asset(_assetAddress);

        //Regular asset purchase or a fractional purchase
        if (asset.assetType() == Asset.AssetTypes.NORMAL) {
            createOrder(_orderId, asset, _qty, _tokenAmount);
        } else {
            //Fractional ownership
            contributeOrder(_orderId, asset, _tokenAmount);            
        }

        return true;
    }

    //@dev for regular normal purchase order
    function createOrder(bytes12 _orderId, Asset _asset, uint _qty, uint _tokenAmount) private {

        uint buyerBalance = splytManager.getBalance(msg.sender);
        uint totalCost = _asset.totalCost() * _qty;
        uint inventoryCount = _asset.inventoryCount();

        if (_tokenAmount < totalCost || buyerBalance < totalCost || _qty > inventoryCount) {
            revert();
        }

        uint mpGets; //marketplaces commission
        uint sellerGets;

        (mpGets, sellerGets) = calcDistribution(totalCost, _asset.getMarketPlacesLength(), _asset.kickbackAmount());
        splytManager.internalContribute(msg.sender, _asset.seller(), sellerGets);
        
        //distribute commission to all the market places
        if(mpGets > 0) {
            for(uint i = 0; i < _asset.getMarketPlacesLength(); i++) {
                splytManager.internalContribute(msg.sender, _asset.getMarketPlaceByIndex(i), mpGets);
            }
        }

        orderData.save(_orderId, address(_asset), msg.sender, _qty, _tokenAmount); //save it to the data contract                
        splytManager.subtractInventory(address(_asset), _qty); //update inventory
        emit Success(4, address(_asset));

    }

    //@dev for fractional purchases
    function contributeOrder(bytes12 _orderId, Asset _asset, uint _tokenAmount) private {
       
        uint buyerBalance = splytManager.getBalance(msg.sender);
        //check if buyer has the amount he proposes to use to contribute
        if (buyerBalance < _tokenAmount) {
            revert();
        }

        // uint orderId = orderData.getFractionalOrderIdByAsset(address(_asset));
        OrderData.Statuses currentStatus = getStatus(_orderId);
        
        OrderData.Statuses updatedStatus;
        //check if theres' existing
        if (currentStatus == OrderData.Statuses.CONTRIBUTIONS_OPEN) {
            uint totalContributions = orderData.getTotalContributions(_orderId) + _tokenAmount;         
            updatedStatus = totalContributions >= _asset.totalCost() ? OrderData.Statuses.CONTRIBUTIONS_FULFILLED : OrderData.Statuses.CONTRIBUTIONS_OPEN;   
            splytManager.internalContribute(msg.sender, address(_asset), _tokenAmount); //transfer contributed amount to asset contract
            orderData.updateFractional(_orderId, msg.sender, _tokenAmount, updatedStatus);       
        } else {
            //create new fractional order
            updatedStatus = _tokenAmount >=  _asset.totalCost() ? OrderData.Statuses.CONTRIBUTIONS_FULFILLED : OrderData.Statuses.CONTRIBUTIONS_OPEN;          
            splytManager.internalContribute(msg.sender, address(_asset), _tokenAmount);  //transfer contributed amount to asset contract
            orderData.saveFractional(_orderId, address(_asset), msg.sender, _tokenAmount, updatedStatus);                      
        }

        //updated asset status to PIF once all contributions are in place
        if (updatedStatus == OrderData.Statuses.CONTRIBUTIONS_FULFILLED) {
            splytManager.internalContribute(address(_asset), _asset.seller(), _asset.totalCost()); //Once all has been contributed, transfer to seller
            splytManager.setAssetStatus(address(_asset), Asset.Statuses.SOLD_OUT);            
        }

        emit Success(2, address(_asset));

    }
 
    function setStatus(bytes12 _orderId, OrderData.Statuses _status) public returns (bool) {

        orderData.setStatus(_orderId, _status); //update the status                
 
        return true;
    }

    function getStatus(bytes12 _orderId) public view returns (OrderData.Statuses) {

        return orderData.getStatus(_orderId);                
 
    }

    function calcDistribution(uint _totalCost, uint _length, uint _kickbackAmount) public pure returns (uint, uint) {
        // Asset asset = Asset(_assetAddress);
        // uint length = asset.getMarketPlacesLength();

        uint kickbackWitheld = _kickbackAmount / _length;
        uint sellerGets = _totalCost - kickbackWitheld * _length;
        return (kickbackWitheld, sellerGets);
    }


    //@dev seller gets refund to buyer and marketplaces
    function approveRefund(bytes12 _orderId) public onlySeller(_orderId) {
        
        uint sellerBalance = splytManager.getBalance(msg.sender);
        uint totalRefundAmount = orderData.getPaidAmount(_orderId);
        uint quantity = orderData.getQuantity(_orderId);

        //make sure seller has enough to refund
        if (sellerBalance < totalRefundAmount) {
            revert();
        }

        uint mpRefunds; //marketplaces commission
        uint buyerRefundFromSeller;
        address assetAddress = orderData.getAssetAddress(_orderId);

        Asset asset = Asset(assetAddress);

        //TODO: check marketplaces have enough balance to refund or error out

        (mpRefunds, buyerRefundFromSeller) = calcDistribution(asset.totalCost(), asset.getMarketPlacesLength(), asset.kickbackAmount());
        splytManager.internalContribute(msg.sender, orderData.getBuyer(_orderId), buyerRefundFromSeller);
        
        //refund commission to buyer from marketplaces
        if(mpRefunds > 0) {
            for(uint i = 0; i < asset.getMarketPlacesLength(); i++) {
                splytManager.internalContribute(asset.getMarketPlaceByIndex(i), orderData.getBuyer(_orderId), mpRefunds);
            }
        }
          
        splytManager.addInventory(assetAddress, quantity); //update inventory
        orderData.setStatus(_orderId, OrderData.Statuses.REFUNDED); //save it to the data contract         

    }
    
    function requestRefund(bytes12 _orderId) public onlyBuyer(_orderId) {
        orderData.setStatus(_orderId, OrderData.Statuses.REQUESTED_REFUND); //save it to the data contract              
    }    

    function getTotalContributions(bytes12 _orderId) public view returns (uint) {
        return orderData.getTotalContributions(_orderId);
    }
    

    function getMyContributions(bytes12 _orderId) public view returns (uint) {
        return orderData.getMyContributions(_orderId, msg.sender);
    }
    

    function setSplytManager(address _address) public onlyOwner {
        splytManager = SplytManager(_address);
    }

    function getDataContractAddress() public view returns (address) {
       return address(orderData);
    }

    function setDataContract(address _orderData) public onlyOwner {
       orderData = OrderData(_orderData);
    }

    function getOrderInfoByOrderId(bytes12 _orderId) public view returns (uint, bytes12, address, address, uint, uint, OrderData.Statuses) {
      return orderData.getOrderByOrderId(_orderId);
    }    

    function getOrderInfoByIndex(uint _index) public view returns (uint, bytes12, address, address, uint, uint, OrderData.Statuses) {
      return orderData.getOrderByOrderId(orderData.orderIdByIndex(_index));
    }    

    function getDataVersion() public view returns (uint) {
      return orderData.version();
    }    

    //@dev will return error if trying to retrieve order id that is not a fractional asset
    function getFractionalOrderIdByAsset(address _assetAddress) public view onlyFractionalAsset(_assetAddress) returns (bytes12) {
        return orderData.getFractionalOrderIdByAsset(_assetAddress);
    }   

    function getOrdersLength() public view returns (uint) {
      return orderData.index();
    }       
   //@dev new manager contract that's going to be replacing this
   //Old manager call this function and proposes the new address
    function transferOwnership(address _newAddress) public onlyOwner {
        orderData.transferOwnership(_newAddress);
    }

    //@dev if new data contract is deployed, the creator proposes manager adress then the manager needs to accept
    function acceptOwnership() public onlyOwner {
        orderData.acceptOwnership();

    }    
    
}