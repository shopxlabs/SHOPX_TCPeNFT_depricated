pragma solidity >= 0.5.13;

import "./ERC20.sol";
import "./SafeMath.sol";

contract SatToken is ERC20 {
    string name;
    uint version;
    string description;
    bool enablePayableFunc = false;
    
    constructor (string memory _name, string memory _description, uint _version) public {
        name = _name;
        version = _version;
        description = _description;
    }
    
    //TODO: Put splyt related $$ transfer logic here
    
    // Temperory give each user 20500 tokens for free
    function initUser(address _user, uint _amount) public {
        user[_user] = _amount;
        totalMinted += _amount;
    }
    
    // This function will trade your ether with sat tokens for you.
    // the only way to attain sat tokens
    function sendSatTokens() public payable returns(bool) {
        if(enablePayableFunc == true) {
            // we are accepting ether in return for tokens
            
        } else {
            // we are NOT accepting ether at this time
            // give the ether back to sender
            msg.sender.transfer(msg.value);
        }
    }
    
    // If someone sends ether to this contract, without specifing a function, it'll end up here
    // in that case send their ether back to them.
    // Commendted out due to making every address variable payable which is too extreme
    // function() external payable {
    //     msg.sender.transfer(msg.value);
    // }
    
}

