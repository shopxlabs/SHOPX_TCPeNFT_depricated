pragma solidity ^0.4.24;

contract SatTokenInterface {
    
    function initUser(address userWallet, uint amount) public;
}

// This contract gives out token to all existing users. update the users array as necessary

contract MigrateSats {
    
    address[] users = [0x02BAAd642568432FFA33722C71B97A90AEb16db5];
    address satTokenAddress = 0x19a22419C418cf0884424760E8577f3429Be5e0A;
    uint public track = 0;
    
    function migrate() public {
        for(uint i = 0; i < 10; i++) {
            SatTokenInterface stInterface = SatTokenInterface(satTokenAddress);
            stInterface.initUser(users[i + track], 205000000);
            track += 1;
        }
    }
    
}