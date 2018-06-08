pragma solidity ^0.4.23;

contract Arbritration {
    
    enum report { SPAM, BROKEN, NOTRECIEVED, NOREASON }
    string public reason;
    address public requestedBy;
    
    constructor(string _reason, address _requestedBy) {
        reason = _reason;
        requestedBy = _requestedBy;
    }
}