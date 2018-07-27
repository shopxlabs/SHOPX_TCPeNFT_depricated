pragma solidity ^0.4.24;

import "./Asset.sol";

contract Order {
    
    enum Reason { DEFECTIVE, NO_REASON, CHANGED_MIND, OTHER }
    enum Status { PAID, CLOSED, REQUESTED_REFUND, REFUNDED, ARBITRATION, OTHER }
    
    address public buyer;
    address public arbitrator;
    Asset public asset;
    uint public quantity;
    Reason public reason;
    Status public status;
    uint public tokenAmount;

    modifier onlyBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    modifier onlySeller(address _seller) {
        require(_seller == asset.seller());
        _;
    }

    modifier onlyArbitrator(address _arbitrator) {
        require(arbitrator == _arbitrator);
        _;
    }

    modifier onlySellerOrArbitrator() {
        require(msg.sender == asset.seller() || msg.sender == arbitrator);
        _;
    }
    
    constructor(address _assetAddress, address _buyer, uint _qty, uint _tokenAmount) public {
        asset = Asset(_assetAddress);
        buyer = _buyer;
        quantity = _qty;
        tokenAmount = _tokenAmount;
    }

    function approvedRefund() public onlySellerOrArbitrator {
        status = Status.REFUNDED;
        //TODO: refund  token process
        
    }
    
    

}