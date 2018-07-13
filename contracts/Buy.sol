pragma solidity ^0.4.24;

import "./Asset.sol";

contract Buy {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { NEW, APPROVED, REJECTED, REFUNDED, OTHER }
    
    address public requestedBy;
    Asset public asset;
    address public buyer;

    modifier onlySellerOrArbitrator() {
        require(msg.sender == asset.seller() || msg.sender == arbitrator);
        _;
    }
    
    constructor(address _assetAddress) public {
        buyer = msg.sender;
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