pragma solidity ^0.4.24;

import './Asset.sol';  //change to interface later

contract Reputation {
    
    enum Statuses { NA, BRONZE, SILVER, GOLD, PLATINUM, DIAMOND }

    bytes12 public reputationId;
    
    struct Review {
        uint rating;
        address from;
        uint date;
    }

    Statuses public status;

    Review[] public reviews;
    uint public totalScore;

    modifier onlyManager() {
        require(ManagerAbstract(msg.sender).isManager(msg.sender) == true);
        _;
    }

    //@dev only within 1-5
    modifier onlyWithinRange(uint _rating) {
        require( _rating > 0 && _rating < 6);
        _;
    }

    //@dev only create new reputation when it creates first review
    constructor(uint _rating, address _from) public onlyWithinRange(_rating){
        status = Statuses.BRONZE;
        reviews.push(Review(_rating, _from, now));   
        totalScore += _rating;     
    }  

    //@dev only accept 100 to 500 
    function addReview(uint _rating, address _from) public onlyWithinRange(_rating) {
        reviews.push(Review(_rating, _from, now));
        totalScore += _rating;
    }  
    
    //@dev get number of reviews
    function getReviewsLength() public view returns (uint) {
        return reviews.length;
    }  
        
    //@dev get number of reviews
    function getReviewByIndex(uint _index) public view returns (uint, address, uint) {
        return (reviews[_index].rating, reviews[_index].from, reviews[_index].date);
    }  
        
}