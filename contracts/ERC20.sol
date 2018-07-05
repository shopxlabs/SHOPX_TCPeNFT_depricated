pragma solidity ^0.4.24;

import "./SafeMath.sol";

contract ERC20 {
    using SafeMath for uint256;
    
    string public constant name = "Splyt Autonomous Tokens";
    string public constant symbol = "SAT";
    uint8 public constant decimals = 4; // We use 4 decimals as of now
    uint constant totalTokensAllowed = 64321684210000; // ~6.4 billion
    uint public totalMinted;
    address trackerAddress;
    
    mapping(address => mapping (address => uint256)) allowed;
    mapping(address => mapping (address => bool)) banned;
    mapping(address => uint) user;
    
    constructor() public {
    }
    
    modifier onlyApprovedOrSplyt(address _from, address _to, uint _value) {
        if(allowed[_from][_to] <= _value || msg.sender == trackerAddress)
            _;
    }
    
    modifier onlyNonBanned(address _from) {
        if(banned[_from][msg.sender] == false)
            _;
    }
    
    
    function totalSupply() public pure returns (uint) {
        return totalTokensAllowed;
    }
    
    function balanceOf(address _owner) public constant returns (uint balance) {
        return user[_owner];
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        
        if (user[msg.sender] >= _value) {
            user[msg.sender] -= _value;
            user[_to] += _value;
            return true;
        }
        return false;
    }
    
    function transferFrom(address _from, address _to, uint _value) public onlyApprovedOrSplyt(_from, _to, _value) onlyNonBanned(_from) returns (bool success) {
        
        if (user[_from] >= _value) {
            user[_from] -= _value;
            user[_to] += _value;
            emit TransferEvent(_from, _to, _value);
            return true;
        }
        return false;
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit ApprovalEvent(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    
    // Get ether balance of this contract
    function getBalance() constant public returns (uint) {
        address a = this;
        return a.balance;
    }
    
    event TransferEvent(address indexed _from, address indexed _to, uint _value);
    event ApprovalEvent(address indexed _owner, address indexed _spender, uint _value);
}