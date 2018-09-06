pragma solidity ^0.4.24;

import './Asset.sol';  //change to interface later

contract Reputation {
    
    //@dev made up for now. TODO: redo theses
    // enum Statuses { NA, BRONZE, SILVER, GOLD, PLATINUM, DIAMOND }

    bytes12 public reputationId;
    
    struct Rate {
        uint rating;
        address from;
        uint date;
    }

    // Statuses public status;
    Rate[] public rates;

    modifier onlyManager() {
        require(ManagerAbstract(msg.sender).isManager(msg.sender) == true);
        _;
    }

    //@dev only create new reputation when it creates first rate
    constructor(uint _rating, address _from) public {
        rates.push(Rate(_rating, _from, now));    
    }  

    //@dev only accept 100 to 500 
    function addRate(uint _rating, address _from) public onlyManager {
        rates.push(Rate(_rating, _from, now));
    }  

    //@dev update rate
    function updateRate(uint _index, uint _rating) public onlyManager {
        rates[_index].rating = _rating;
        rates[_index].date = now;
    }  

    //@dev get number of rates
    function getRatesLength() public view returns (uint) {
        return rates.length;
    }  
        
    //@dev get review information
    // function getRateByIndex(uint _index) public view returns (uint, address, uint) {
    //     return (rates[_index].rating, rates[_index].from, rates[_index].date);
    // } 
    //@dev get date
    function getDateByIndex(uint _index) public view returns (uint) {
        return rates[_index].date;
    }       
    //@dev get reviewer
    function getRaterByIndex(uint _index) public view returns (address) {
        return rates[_index].from;
    }  
    //@dev get reviewer
    function getRatingByIndex(uint _index) public view returns (uint) {
        return rates[_index].rating;
    }  
}