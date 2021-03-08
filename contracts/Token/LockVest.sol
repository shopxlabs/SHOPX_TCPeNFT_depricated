// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "../Utils/Owned.sol";
import "../Utils/SafeMath.sol";

interface IToken {
    function mint(address account, uint256 amount) external;
}

contract LockVestManager is Owned {
    
    using SafeMath for uint256;

    IToken tokenInstance;
    // owner who has tokens locked/vested, lockType dictates how long to lock for and when to start vesting
    mapping(address => uint8) vestors;
    //Total amount allowed
    mapping(address => uint256) tokensAllowed;
    // lock end and vesting start dates. advisors, team, research
    uint256[3] lockEndDates = [1622444400, 1648710000, 1635663600];
    //vesting months. advisors, team, research
    uint256[3] vestingPeriod = [24, 24, 60];
    //Seconds in a month(30.44 days)
    uint256 aMonth = 2629743;
    event Allocated(address wallet, uint256 lockedTill);

    constructor(address _token) {
        tokenInstance = IToken(_token);
    }
    
    // only owner can allocate to vestors
    function allocate(address _vestor, uint8 _lockType, uint256 _totalAmount) public returns(uint256 unlockDate) {
        vestors[_vestor] = _lockType;
        tokensAllowed[_vestor] = _totalAmount;
        emit Allocated(_vestor, lockEndDates[_lockType]);
        return lockEndDates[_lockType];
    }
    
    
    // vestors can call this function to mint tokens for them
    function mint() public returns(uint256 tokens) {
        // check now >= lockends
        require(block.timestamp >= lockEndDates[vestors[msg.sender]], "tokens are locked");
        // check howmany months passed since lockends
        uint256 diffSeconds = block.timestamp.sub(lockEndDates[vestors[msg.sender]]);
        uint256 monthsSinceVesting = diffSeconds.div(aMonth);
        
        
        //TODO: calculate howmany tokens should be minted based on 2629743 seconds as 1 month

        tokenInstance.mint(msg.sender, tokensAllowed[msg.sender]);
        //TODO: substract from totalTokensAllowed for that account
        return tokensAllowed[msg.sender];
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
 
    // mapping(address => address[]) wallets;

    // function getWallets(address _user) public view returns(address[])
    // {
    //     return wallets[_user];
    // }

    // function create(address _owner, uint256 _unlockDate) public returns(address lockVest) {
    
    //     lockVest = new LockVest(msg.sender, _owner, _unlockDate);
        
    //     wallets[msg.sender].push(wallet);

    //     if(msg.sender != _owner){
    //         wallets[_owner].push(wallet);
    //     }

    //     wallet.transfer(msg.value);

    //     // Emit event.
    //     Created(wallet, msg.sender, _owner, now, _unlockDate, msg.value);
    //     return lockVest;
    // }

    // // Prevents accidental sending of ether to the factory
    // fallback () public {
    //     revert();
    // }

}