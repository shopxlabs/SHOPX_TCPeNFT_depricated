pragma solidity ^0.4.23;

contract ERC20 {
    
    string public constant name = "Splyt Autonomous Tokens";
    string public constant symbol = "SAT";
    uint8 public constant decimals = 0; // We don't use decimals as of now
    uint constant totalTokensAllowed = 6432168421; // ~6.4 billion
    uint public totalMinted;
    
    
    struct Meta {
        uint balance;
        mapping(address => uint) allowance;
    }
    mapping(address => Meta) user;
    
    modifier onlyOnce() {
        if(user[msg.sender].balance == 0) _;
    }
    
    constructor() public {
        initUser(msg.sender);
    }
    
    function totalSupply() public pure returns (uint) {
        return totalTokensAllowed;
    }
    
    function balanceOf(address _owner) public constant returns (uint balance) {
        return user[_owner].balance;
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        
        if (user[msg.sender].balance >= _value) {
            user[msg.sender].balance -= _value;
            user[_to].balance += _value;
            return true;
        }
        return false;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        
        if (user[_from].balance >= _value) {
            user[_from].balance -= _value;
            user[_to].balance += _value;
            emit TransferEvent(_from, _to, _value);
            return true;
        }
        return false;
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        user[msg.sender].allowance[_spender] = _value;
        emit ApprovalEvent(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return user[_owner].allowance[_spender];
    }
    
    /**
     *  Splyt specific functionality
    */
    
    // Temperory give each user 2000 tokens for free
    function initUser(address _user) public {
        user[_user].balance = 20500;
        totalMinted += 20500;
    }
    
    // Get ether balance of this contract
    function getBalance() constant public returns (uint) {
        address a = this;
        return a.balance;
    }
    
    event TransferEvent(address indexed _from, address indexed _to, uint _value);
    event ApprovalEvent(address indexed _owner, address indexed _spender, uint _value);
}