// SPDX-License-Identifier: MIT
pragma solidity 0.7.3;

import "./ERC20.sol";
import "../Utils/SafeMath.sol";

// Splyt logic on top of standard erc20 contract
abstract contract ShopxToken is ERC20 {
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
    
    modifier onlyNonBanned(address _from) {
        if(_banned[_from][msg.sender] == false)
            _;
    }
        
}

