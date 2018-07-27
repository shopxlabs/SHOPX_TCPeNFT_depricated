pragma solidity ^0.4.24;

import "./Asset.sol";
import "./Owned.sol";

contract Arbitration {
    
    enum Reasons { SPAM, BROKEN, NOTRECIEVED, NOREASON }
    string public reason;
    address public requestedBy;
    Asset asset;

    constructor(address _assetAddress, Reasons _reason, address _requestedBy) public {
        reason = _reason;
        requestedBy = _requestedBy;
        asset = Asset(_assetAddress);
    }
}