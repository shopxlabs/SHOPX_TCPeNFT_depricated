pragma solidity >= 0.4.24;

import "./Owned.sol";

contract ReputationData is Owned {
    
    mapping (address => address) public reputationByWallet;
    mapping (uint => address) public reputationByIndex;
        
    uint public index;
    //TODO: add modifier t only let new                                                                          
    function save(address _wallet, address _reputation) public onlyOwner returns (bool) {
        reputationByWallet[_wallet] = _reputation;
        reputationByIndex[index] = _reputation;
        index++;
        return true;
    }  
    
}