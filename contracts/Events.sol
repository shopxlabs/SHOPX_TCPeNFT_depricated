pragma solidity ^0.4.24;

// Events to notify other market places of something
// Success events gets triggered when a listing is created or a listing is fully/partially funded
// _code: 1 = listing created, 
//        2 = contributions came in 
//        3 = arbitration happend. Spam reported
//        4 = arbitration response by seller after being reported
// _assetAddress: the asset address for which the code happened
// event Success(uint _code, address _assetAddress);
// event Error(uint _code, string _message);

contract Events {
    
    event Error(uint _code, address _assetAddress, string _message);
    event Success(uint _code, address _assetAddress);
}