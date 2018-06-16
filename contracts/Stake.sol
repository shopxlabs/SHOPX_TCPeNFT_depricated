pragma solidity ^0.4.24;

contract Stake {
    
    // Equation: (1,000,000/ (X + 100,000)) * 100
    // Where X is the total cost of item, eqVar1 == 1,000,000, eqVar2 == 100,000, eqVar3 == 100
    
    uint eqVar1;
    uint eqVar2;
    uint eqVar3;
    
    constructor(uint _eqVar1, uint _eqVar2, uint _eqVar3) public {
        eqVar1 = _eqVar1;
        eqVar2 = _eqVar2;
        eqVar3 = _eqVar3;
    }
    
    function calcStakePercentage(uint _itemCost) public constant returns (uint numer, uint denom, uint axe, uint percentage) {
        axe = eqVar3*_itemCost;
        denom = axe + eqVar2;
        percentage = eqVar1 / denom;
        return (eqVar1, denom, axe, percentage);
    }
    // _itemCost original cost of the item
    // return uint to 4 decimal places
    function calcStake(uint _itemCost) public constant returns (uint) {
        //calculate  staking % based on item cost here
        return (_itemCost * 10000 * 4000) / 100000; 
    }
    
    
    
}