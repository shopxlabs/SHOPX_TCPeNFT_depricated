pragma solidity ^0.4.24;

import './Asset.sol';  //change to interface later
import './Owned.sol';  //change to interface later

contract User is Owned {
    
    enum UserTypes { BUYER, SELLER, MARKET_PLACE  }
    enum Statuses { ACTIVE, CLOSED, SUSPENDED }

    address wallet;

    UserTypes public userType;
    Statuses public status;


    constructor(address _wallet, UserTypes _type) public {
        wallet = _wallet;
        userType = _type;
        status = Statuses.ACTIVE;
    }  
    

}