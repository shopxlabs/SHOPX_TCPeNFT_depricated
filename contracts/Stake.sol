pragma solidity >= 0.4.24;

import "./SafeMath.sol";

contract Stake {
    
    // Equation: 1,000,000,000,000,000 / x + 200,000,000,000
    // Deploy params: 1000000000000000, 200000000000
    // Where X is the total cost, eqVar1 == 1,000,000,000,000,000, eqVar2 == 200,000,000,000
    
    uint public eqVar1;
    uint public eqVar2;

    constructor(uint _eqVar1, uint _eqVar2) public {
        setConstants(_eqVar1, _eqVar2);
    }
    
    // change change constants if need to after deploying the contract
    function setConstants(uint _eqVar1, uint _eqVar2) public {
        eqVar1 = _eqVar1;
        eqVar2 = _eqVar2;
    }
    
    //calculates staking percentages, all returns need to be multiplied by 10^5 to convert to
    //percentages in decimal format
    function calcStakePercentage(uint _itemCost) public view returns (uint stakePercent) {
        uint denom = SafeMath.add(_itemCost, eqVar2);
        return SafeMath.div(eqVar1, denom);
    }
    
    function calculateStakeTokens(uint _itemCost) public view returns(uint stakeTokens) {
        
        return (SafeMath.div(SafeMath.mul(_itemCost, calcStakePercentage(_itemCost)), 100000));
    }
}