pragma solidity ^0.4.23;

import 'browser/ERC20.sol';

contract SatToken is ERC20 {
    string name;
    uint version;
    string description;
    address public trackerAddr;
    
    constructor (string _name, string _description, uint _version) public {
        name = _name;
        version = _version;
        description = _description;
    }
    
    //TODO: Put splyt related $$ transfer logic here
}

