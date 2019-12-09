pragma solidity >= 0.5.13;


contract SplytPriceOracle {

  // price in usd for 1 ether
  uint public ethUSD  = 0;
  address owner;

  modifier onlyOwner() {
    assert(msg.sender == owner);
    _;
  }

  constructor() public {
    owner = msg.sender;
  }

  function setEthUsd(uint _dollars) public {
    ethUSD = _dollars;
  }

  function getEthUsd() public view returns (uint) {
    return ethUSD;
  }
}