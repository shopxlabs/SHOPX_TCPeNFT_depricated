pragma solidity ^0.4.24;

import "./Asset.sol";

contract Order {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    address public buyer;
    address public arbitrator;
    Asset public asset;
    Reason public reason;
    Status public status;
    

    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
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
    
    constructor(address _assetAddress) public {
        asset = Asset(_assetAddress);
    }

    function requestRefund() public onlyBuyer {
        status = Status.REQUESTED_REFUND;
    }

    function approvedRefund() public onlySellerOrArbitrator {
        status = Status.REFUNDED;
        //TODO: refund  token process
        
    }

}