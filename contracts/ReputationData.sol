pragma solidity ^0.4.24;

import "./Owned.sol";

contract ReputationData is Owned {
    
    mapping (address => address) public reputationByWallet;
    mapping (uint => address) public reputationByIndex;
        
    uint public index;
                                                                          
    function save(address _wallet, address _reputation) public onlyOwner returns (bool) {
        reputationByWallet[_wallet] = _reputation;
        reputationByIndex[index] = _reputation;
        index++;
        return true;
    }  
    
    function getReputationByWallet(address _wallet) public view returns (address) {
        return reputationByWallet[_wallet];
    }   
       
    function getReputationByIndex(uint _index) public view returns (address) {
        return reputationByIndex[_index];
    }   

    function getLength() public view returns (uint) {
        return index;
    } 
}