// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "../Utils/SafeMath.sol";

// Standard erc20 contract used from template
contract ERC20 {
    using SafeMath for uint256;
        
    string private _name = "Splyt SHOPX Token";
    string private _symbol = "SHOPX";
    uint8 private _decimals = 18; // 18 decimal places for protocol
    uint256 public _totalSupply = 500000000000000000000000000; // 0.5 billion
        
    mapping(address => uint256) _balances;
    mapping(address => mapping (address => uint256)) _allowances;
    
    uint256 public _totalMinted;
    
    string private _errZeroAddress = "zero address not allowed";
    
    
    constructor() {}
    
    //Interface for getters
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    


    // Interface for setters
    function transfer(address recipient, uint amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    // function transferFrom(address sender, address recipient, uint amount) public returns (bool success) {
    //     _transfer(sender, recipient, amount);
    //     _approve(sender, tx.origin, _allowances[sender][tx.origin].sub(amount, "Transfer amount exceeds allowance"));
    //     return true;
    // }

    // TODO: fix above function so splyt and approved are allowed to move tokens like below function
    // function transferFrom(address sender, address recipient, uint amount) public 
    // onlyApprovedOrSplyt(_from, _to, _value) onlyNonBanned(_from) returns (bool success) {
    //     _transfer(sender, recipient, amount);
    //     _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
    //     return true;
    // }
    
    // function approve(address spender, uint256 amount) public virtual returns (bool) {
    //     _approve(tx.origin, spender, amount);
    //     return true;
    // }
    
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    

    // Internal functions
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0) && recipient != address(0), "Transfer from and to zero address not allowed");

        _balances[sender] = _balances[sender].sub(amount, "Transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    // function _approve(address owner, address spender, uint256 amount) internal virtual {
    //     require(owner != address(0), "Approve from " + _errZeroAddress);
    //     require(spender != address(0), "Approve to " + _errZeroAddress);

    //     _allowances[owner][spender] = amount;
    //     emit Approval(owner, spender, amount);
    // }
    
    event Transfer(address indexed sender, address indexed recipient, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}