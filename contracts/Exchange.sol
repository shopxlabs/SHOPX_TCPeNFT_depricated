pragma solidity ^0.5.13;

import './Owned.sol';  //change to interface later

contract Exchange is Owned {
        
    uint public currentRate;

    //@dev 4 assumed decimals
    constructor(uint _exchangeRate) public {
        currentRate = currentRate;
    }  
    
    //@dev set rate per token
    function setExchangeRate(uint _exchangeRate) public onlyOwner {
        currentRate = _exchangeRate;
    }    

    //@dev convert wei to tokens
    function convertWeiTokens(uint _wei) public view returns (uint) {
        return (_wei * currentRate);
    } 

}