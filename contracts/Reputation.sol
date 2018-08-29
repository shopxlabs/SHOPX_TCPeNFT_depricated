pragma solidity ^0.4.24;

import './Asset.sol';  //change to interface later

contract Reputation {
    
    enum Statuses { NA, BRONZE, SILVER, GOLD, PLATINUM, DIAMOND }

    bytes12 public reputationId;
    
    struct Reporter {
        uint rating;
        address from;
        uint date;
    }

    Statuses public status;

    Reporter[] reporters;

    modifier onlyManager() {
        require(ManagerAbstract(msg.sender).isManager(msg.sender) == true);
        _;
    }

    constructor(uint _rating, address _from) public {
        status = Statuses.BRONZE;
        reporters.push(Reporter(_rating, _from, now));        
    }  

    function add(uint _rating, address _from) public {
        reporters.push(Reporter(_rating, _from, now));
    }  
    
    function getRating() public view returns (uint) {
       
       uint score;

       for (uint i=0; i < reporters.length; i++) {
            score += reporters[i].rating; 
       }

       return (score / reporters.length);
    } 

}