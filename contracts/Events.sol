pragma solidity ^0.4.23;

// This contract will handle all events that needs to be emitted. 
// Some of them includes: success events, error events. 
// Successfully added an asset.
// Errored out adding an asset.

contract Events {
    
    event Error(uint _code, string _message);
    event Success(uint _code, address _assetAddress);
}