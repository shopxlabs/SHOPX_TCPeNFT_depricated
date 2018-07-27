pragma solidity ^0.4.24;

contract Arbitration {
    
    enum report { SPAM, BROKEN, NOTRECIEVED, NOREASON }
    string public reason;
    address public requestedBy;
    
    constructor(string _reason, address _requestedBy) public {
        reason = _reason;
        requestedBy = _requestedBy;
    }
}