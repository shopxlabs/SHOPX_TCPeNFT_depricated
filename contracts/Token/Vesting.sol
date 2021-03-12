// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "../Utils/Owned.sol";
import "../Utils/SafeMath.sol";
import "./IERC20.sol";


contract Vesting is Owned {
    
    using SafeMath for uint256;

    uint256  internal _cliff;
    uint256 internal _start;
    uint256 internal _duration;
    bool    internal _revocable;
    address internal _revokeTo;
    address internal _beneficiary;
    
    uint16 internal _firstMonthPercent;
    uint256 internal _aMonth = 2629743;
    
    mapping (address => uint256) private _released;
    mapping (address => bool)    private _revoked;


    /**
    * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
    * beneficiary, gradually in a linear fashion until start + duration. By then all
    * of the balance will have vested.
    * @param beneficiary_ address of the beneficiary to whom vested tokens are transferred
    * @param cliffDuration_ duration in seconds of the cliff in which tokens will begin to vest (seconds of cliff after start)
    * @param start_ the time (as Unix time) at which point vesting starts (current timestamp)
    * @param duration_ duration in seconds of the period in which the tokens will vest (total seconds including cliffDuration)
    * @param revocable_ whether the vesting is revocable or not
    * @param revokeTo_ revoke tokens to this address
    * @param firstMonthPercent_ diff in percentage between 1st month and rest
    */
    constructor(address beneficiary_, uint256 start_, uint256 cliffDuration_, uint256 duration_, bool revocable_, address revokeTo_, uint16 firstMonthPercent_) {
        require(beneficiary_ != address(0), "TokenVesting: beneficiary is the zero address");
        require(cliffDuration_ <= duration_, "TokenVesting: cliff is longer than duration");
        require(duration_ > 0, "TokenVesting: duration is 0");
        require(start_.add(duration_) > block.timestamp, "TokenVesting: final time is before current time");
        
        _beneficiary =  beneficiary_;
        _cliff =        start_.add(cliffDuration_);
        _start =        start_;
        _duration =     duration_;
        _revocable =    revocable_;
        _revokeTo =     revokeTo_;
        
        _firstMonthPercent = firstMonthPercent_;
    }

    //getters
    function beneficiary() public view returns(address) {
        return _beneficiary;
    }

    function cliff() external view returns(uint256) {
        return _cliff;
    }

    function start() public view returns(uint256) {
        return _start;
    }

    function duration() public view returns(uint256) {
        return _duration;
    }

    function revocable() public view returns(bool) {
        return _revocable;
    }

    function released(address token) public view returns(uint256) {
        return _released[token];
    }

    function revocked(address token) public view returns(bool) {
        return _revoked[token];
    }

    //setters
    function release(IERC20 token) public {
        uint256 unreleased = _releasableAmount(token);

        require(unreleased > 0, "TokenVesting: no tokens are due");

        _released[address(token)] = _released[address(token)].add(unreleased);

        token.transfer(_beneficiary, unreleased);

        emit TokensReleased(address(token), unreleased);
    }

    function revoke(IERC20 token) onlyOwner public {
        require(_revocable, "TokenVesting: cannot revoke");
        require(!_revoked[address(token)], "TokenVesting: token already revoked");

        uint256 balance = token.balanceOf(address(this));

        uint256 unreleased = _releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        _revoked[address(token)] = true;

        token.transfer(_revokeTo, refund);

        emit TokenVestingRevoked(address(token));
    }

    function _releasableAmount(IERC20 token) private view returns (uint256) {
        return _vestedAmount(token).sub(_released[address(token)]);
    }

    function _vestedAmount(IERC20 token) private view returns (uint256) {
        uint256 currentBalance = token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(_released[address(token)]);
        uint256 snappedTimestamp = block.timestamp.sub(block.timestamp.mod(_aMonth));
        
        if (block.timestamp < _cliff) {
            return 0;
        } else if (snappedTimestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            uint256 firstMonthBonus = totalBalance.mul(_firstMonthPercent).div(100);
            uint256 restMonth = totalBalance.mul(snappedTimestamp.sub(_start)).div(_duration);
            if(_released[address(token)] == 0) {
                restMonth.add(firstMonthBonus);
            }
            return restMonth;
        }
    }
    
    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

}