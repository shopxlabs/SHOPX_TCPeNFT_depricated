pragma solidity ^0.4.24;

import "./Asset.sol";
import "./Managed.sol";

contract Order is Managed {
    
    enum Reasons { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Statuses { PIF, CLOSED, REQUESTED_REFUND, REFUNDED, OTHER }

    uint public orderId;    
    address public buyer;
    Asset public asset;
    uint public quantity;
    Reasons public reason;
    Statuses public status;
    uint public tokenAmount;

    modifier onlyBuyer() {
        require(buyer == msg.sender);
        _;
    }
    
    modifier onlySeller() {
        require(asset.seller() == msg.sender);
        _;
    }
    
    constructor(address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public {
        // orderId = _orderId;
        asset = Asset(_assetAddress);
        buyer = _buyer;
        quantity = _qty;
        tokenAmount = _tokenAmount;
        status = Statuses.PIF;
    }

    function approveRefund() public onlySeller {
        status = Statuses.REFUNDED;
        //TODO: refund  token process
        
    }
    
    function requestRefund() public onlyBuyer {
        status = Statuses.REQUESTED_REFUND;
        //TODO: refund  token process        
    }    

}