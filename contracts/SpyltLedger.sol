pragma solidity ^0.4.24;

// This contracts keeps track how much a wallet has funded
// Transfer Ether to spylt wallet
contract SpyltLedger {

    uint maxEthers = 1000 ether; //Cap of how much it can receive.
    uint totalFunds; //total fund received. This should match the total amouont transfer from this contract to spylt wallet 
    address spyltWallet; //cold spylt wallet preferably
    
    //@desc all the funders
    mapping (address => uint) public fundersMap;
    address[] public funders; //this is used to iterate through each since you cannot iterate through mapping natively
 
    modifier onlyBelowCap () {
        require (totalFunds + msg.value < maxEthers);
        _;
    }   
    
    constructor() public {
        spyltWallet = msg.sender; //change to spylt cold wallet
    }
    
    //@desc this function gets called funders send ethers to this contract address
    function() public payable onlyBelowCap {
        fundersMap[msg.sender] =  fundersMap[msg.sender] + msg.value;
        funders.push(msg.sender);
        totalFunds += msg.value;
        spyltWallet.transfer(msg.value);
    }   
    
    //@desc should be zero since it transfer the funded amount to splyt cold wallet
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }   
    
}