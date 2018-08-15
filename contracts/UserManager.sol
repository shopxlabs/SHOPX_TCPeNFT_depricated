pragma solidity ^0.4.24;

import "./Owned.sol";
import "./UserData.sol";
import "./Asset.sol";
import "./User.sol";
import "./SplytManager.sol";

contract UserManager is Owned {

    SplytManager public splytManager;
    UserData public userData;
    
    //middlware only arbitrator 
    // modifier onlyArbitrator(address _arbitrationAddress) {
    //     require(Arbitration(_arbitrationAddress).arbitrator() == msg.sender);
    //     _;
    // }

    // modifier onlyReporter(address _arbitrationAddress) {
    //     require(Arbitration(_arbitrationAddress).reporter() == msg.sender);        
    //     _;
    // }
        
    // modifier onlySeller(address _arbitrationAddress) {
    //     address assetAddress = Arbitration(_arbitrationAddress).asset();
    //     require(Asset(assetAddress).seller() == msg.sender);        
    //     _;
    // }
        

    constructor(address _splytManager) public {
        splytManager = SplytManager(_splytManager);
        userData = new UserData();
        owner = msg.sender;
    }

    function createUser(address _userWallet, User.UserTypes _type) public {

        User user = new User(_userWallet, _type);
        userData.save(_userWallet, user);      
    }


   
}