// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "./VestingOwned.sol";
import "./Owned.sol";
import "../Utils/SafeMath.sol";
import "./IERC20.sol";


contract Vesting is Owned {
    
    using SafeMath for uint256;

    uint16  internal _cliff;
    uint256 internal _start;
    uint256 internal _duration;
    bool    internal _revocable;
    address internal _revokeTo;
    address internal _beneficiary;
    
    mapping (address => uint256) private _released;
    mapping (address => bool)    private _revoked;


    constructor(address beneficiary_, uint16 cliff_, uint256 start_, uint256 duration_, bool revocable_, address revokeTo_) {
        _beneficiary =  beneficiary_;
        _cliff =         cliff_;
        _start =         start_;
        _duration =      duration_;
        _revocable =     revocable_;
        _revokeTo =      revokeTo_;
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

    function released(address token) public returns(uint256) {
        return _released[token];
    }

    function revocked(address token) public returns(bool) {
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

        if (block.timestamp < _cliff) {
            return 0;
        } else if (block.timestamp >= _start.add(_duration) || _revoked[address(token)]) {
            return totalBalance;
        } else {
            return totalBalance.mul(block.timestamp.sub(_start)).div(_duration);
        }
    }
    
    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

}