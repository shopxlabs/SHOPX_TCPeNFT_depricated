pragma solidity ^0.4.24;

contract Stake {
    
    // Equation: 10,000,000,000,000/ (100X + 2,000,000,000)
    // 10000000000000, 2000000000, 100
    // Where X is the total cost of item say 4, eqVar1 == 1,000,000, eqVar2 == 100,000, eqVar3 == 100
    
    uint eqVar1;
    uint eqVar2;
    uint eqVar3;
    
    constructor(uint _eqVar1, uint _eqVar2, uint _eqVar3) public {
        setConstants(_eqVar1, _eqVar2, _eqVar3);
    }
    
    function setConstants(uint _eqVar1, uint _eqVar2, uint _eqVar3) public {
        eqVar1 = _eqVar1;
        eqVar2 = _eqVar2;
        eqVar3 = _eqVar3;
    }
    
    function calcStakePercentage(uint _itemCost) public view returns (uint percentage) {
        uint axe = eqVar3 * _itemCost;
        uint denom = axe + eqVar2;
        percentage = eqVar1 / denom;
        
        return percentage;
    }
    
    function calculateStakeTokens(uint _itemCost) public view returns(uint _stakeTokens) {
        return (_itemCost * calcStakePercentage(_itemCost)) / 100000;
    }
}