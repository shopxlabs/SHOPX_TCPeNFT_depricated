// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./ArbitrationManager.sol";
import "./Asset.sol";
import "./AssetManager.sol";
import "./OrderData.sol";
import "./SplytManager.sol";
import "../Utils/Owned.sol";
import "../Utils/Events.sol";


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

    constructor(address _splytManager) {
        orderData = new OrderData();
        splytManager = SplytManager(_splytManager); //splytManager address
    }

    //@dev buyer must pay it in full to create order
    // To succcessfully purchase an asset, buy must purchase the whole amount times the quantity.
    // The asset must be in 'ACTIVE' status.    
    function purchase(bytes12 _orderId, address _assetAddress, uint _qty, uint _tokenAmount, address _marketPlace) public onlyAssetStatus(Asset.Statuses.ACTIVE, _assetAddress) returns (bool) {

        Asset asset = Asset(_assetAddress);

        //add to marketplace
        splytManager.addMarketPlace(_assetAddress, _marketPlace);

        //Regular asset purchase or a fractional purchase
        if (asset.assetType() == Asset.AssetTypes.NORMAL) {
            createOrder(_orderId, asset, _qty, _tokenAmount);
        } else {
            //Fractional ownership. check if already exist
            bytes12 fractionalOrderId = orderData.fractionalOrders(_assetAddress);
            if (fractionalOrderId == bytes12(0)) {
                fractionalOrderId = _orderId;
            }
            contributeOrder(fractionalOrderId, asset, _tokenAmount);   
        }

        return true;
    }

    //@dev for regular normal purchase order
    function createOrder(bytes12 _orderId, Asset _asset, uint _qty, uint _tokenAmount) private {

        uint buyerBalance = splytManager.getBalance(msg.sender);
        uint totalCost = _asset.totalCost() * _qty;

        uint inventoryCount = _asset.inventoryCount();

        // uint updatedBalance = buyerBalance - totalCost; //used to prevent Reentrancy Attack
        // if (updatedBalance < 0) {
        //     revert()
        // }

        assert(totalCost <= _tokenAmount && totalCost < buyerBalance && _qty <= inventoryCount);

        uint mpGets; //marketplaces commission
        uint sellerGets;
        uint mpLength;
        uint i = 0;

        if(_asset.isOnlyAffiliate()) {
            mpLength = _asset.getMarketPlacesLength() - 1;
            i = 1;
        } else {
            mpLength = _asset.getMarketPlacesLength();
        }
                         
        (mpGets, sellerGets) = calcDistribution(totalCost, mpLength, _asset.kickbackAmount());
       
        splytManager.internalContribute(msg.sender, _asset.seller(), sellerGets);
        
        // distribute commission to all the market places
        if(mpGets > 0) {
            for(i; i < _asset.getMarketPlacesLength(); i++) {
                splytManager.internalContribute(msg.sender, _asset.getMarketPlaceByIndex(i), mpGets);
            }
        }

        //return stake to seller
        splytManager.internalContribute(address(_asset), _asset.seller(), (_asset.initialStakeAmount() * _qty));

        orderData.save(_orderId, address(_asset), msg.sender, _qty, _tokenAmount); //save it to the data contract                
        splytManager.subtractInventory(address(_asset), _qty); //update inventory
        emit Success(4, address(_asset));

    }

    //@dev for fractional purchases
    function isFractionalOrderExists(address _asset) public view returns (bool) {
        bytes12 fractionalOrderId = orderData.fractionalOrders(_asset);
        if (fractionalOrderId == bytes12(0)) {
            return false;
        } else {
            return true;
        }

    }

    //@dev for fractional purchases
    function contributeOrder(bytes12 _orderId, Asset _asset, uint _tokenAmount) private {
       
        uint buyerBalance = splytManager.getBalance(msg.sender);
        //check if buyer has the amount he proposes to use to contribute
        assert(_tokenAmount < buyerBalance);

        // uint orderId = orderData.getFractionalOrderIdByAsset(address(_asset));
        OrderData.Statuses currentStatus = getStatus(_orderId);
        
        OrderData.Statuses updatedStatus;
        //check if theres' existing
        if (currentStatus == OrderData.Statuses.CONTRIBUTIONS_OPEN) {
            uint totalContributions = orderData.getTotalContributions(_orderId) + _tokenAmount;         
            updatedStatus = totalContributions >= _asset.totalCost() ? OrderData.Statuses.CONTRIBUTIONS_FULFILLED : OrderData.Statuses.CONTRIBUTIONS_OPEN;   
            splytManager.internalContribute(msg.sender, address(_asset), _tokenAmount); //transfer contributed amount to asset contract
            orderData.addContribution(_orderId, msg.sender, _tokenAmount, updatedStatus);       
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

    function setSplytManager(address _address) public onlyOwner {
        splytManager = SplytManager(_address);
    }

    function getDataContractAddress() public view returns (address) {
       return address(orderData);
    }

    function setDataContract(address _orderData) public onlyOwner {
       orderData = OrderData(_orderData);
    }

    function getFractionOrderIdByAssetAddress(address _asset) public view returns (bytes12) {
      return orderData.fractionalOrders(_asset);
    }    


    function getOrderInfoByOrderId(bytes12 _orderId) public view returns (uint, bytes12, address, address, uint, uint, OrderData.Statuses) {
      return orderData.getOrderByOrderId(_orderId);
    }    

    function getOrderInfoByIndex(uint _index) public view returns (uint, bytes12, address, address, uint, uint, OrderData.Statuses) {
      return orderData.getOrderByOrderId(orderData.orderIdByIndex(_index));
    }    


    function getContributionsLength(bytes12 _orderId) public view returns (uint) {
      return orderData.getContributionsLengthByOrderId(_orderId);
    }    


    function getContributionByOrderIdAndIndex(bytes12 _orderId, uint _index) public view returns (address, uint, uint) {
      return orderData.getContributionByOrderIdAndIndex(_orderId, _index);
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
    
}
