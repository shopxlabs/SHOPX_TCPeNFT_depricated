pragma solidity ^0.4.24;

import "./Asset.sol";

contract Return {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { NEW, APPROVED, REJECTED, REFUNDED, OTHER }
    
    address public requestedBy;
    Asset public asset;
    Reason public reason;
    Status public status;
    address public arbitrator;
    
    modifier onlySeller() {
        require(msg.sender == asset.seller());
        _;
    }

    modifier onlyArbitrator() {
        require(msg.sender == arbitrator);
        _;
    }

    modifier onlySellerOrArbitrator() {
        require(msg.sender == asset.seller() || msg.sender == arbitrator);
        _;
    }
    
    constructor(Reason _reason, address _assetAddress) public {
        reason = _reason;
        asset = Asset(_assetAddress);
    }

    function setStatus(Status _status) public onlySellerOrArbitrator {
        status = _status;
        if (status == Status.APPROVED) {
            //TODO: refund tokens process
            status = Status.REFUNDED;
        }
    }

    
}