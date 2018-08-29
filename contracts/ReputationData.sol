pragma solidity ^0.4.24;

import "./Owned.sol";

contract ReputationData is Owned {
    
    mapping (address => address) public reputationByWallet;
                                     
    function save(address _wallet, address _reputation) public onlyOwner returns (bool) {
        reputationByWallet[_wallet] = _reputation;
        return true;
    }  
    
    function getReputationByWallet(address _wallet) public view returns (address) {
        return reputationByWallet[_wallet];
    }   
       

}