// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./ERC20.sol";
import "../Utils/SafeMath.sol";
import "../Utils/Owned.sol";

// Splyt logic on top of standard erc20 contract
contract ShopxToken is ERC20, Owned {
    using SafeMath for uint256;

    uint public  _version;
    bool public _pauseMint;
    address public _trackerAddress;
    mapping(address => mapping (address => bool)) _banned;
    
    constructor (uint version) {
        _version = version;
        _pauseMint = true;
    }

    function pause(bool pauseUnpause) public {
        require(_pauseMint != pauseUnpause, "Same value supplied as current state");
        _pauseMint = pauseUnpause;
    }

    //Splyt related logic to allow based on platform behaviour
    // Might not be needed if splyt will use allowance style 
    // modifier onlyApprovedOrSplyt(address _from, address _to, uint _value) {
    //     if(allowed[_from][_to] <= _value || msg.sender == trackerAddress)
    //         _;
    // }
    
    function _beforeMint(address account, uint256 amount) internal virtual {
        //minting to 0 address not allowed
        require(account != address(0), "Mint to zero address not allowed");
        //must be unpause to proceed
        require(!_pauseMint, "Minting is paused");
        //total supply reached
        require(_totalMinted + amount <= _totalSupply, "Total supply reached");
    }
    
    
    function mint(address account, uint256 amount) public virtual {
        _beforeMint(account, amount);

        _totalMinted = _totalMinted.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
    }


    modifier onlyNonBanned(address _from) {
        if(_banned[_from][msg.sender] == false)
            _;
    }
    
    fallback() external payable {
        revert();
    }
    
}

