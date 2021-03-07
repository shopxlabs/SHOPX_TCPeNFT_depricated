// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "../Utils/SafeMath.sol";

// Standard erc20 contract used from template
contract ERC20 {
    using SafeMath for uint256;
        
    uint256 private _totalSupply = 500000000; // ~500 million
    string private _name = "Splyt SHOPX Token";
    string private _symbol = "SHOPX";
    uint8 private _decimals = 4; // 4 decimal places for protocol
    mapping(address => uint256) _balances;
    mapping(address => mapping (address => uint256)) _allowances;
    
    uint public _version;
    uint256 public _totalMinted;
    address _trackerAddress;
    mapping(address => mapping (address => bool)) _banned;
    string private _errZeroAddress = "zero address not allowed";
    
    
    constructor(uint version) public {
        _version = version;
    }
    
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
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    


    // Interface for setters
    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool success) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

    // TODO: fix above function so splyt and approved are allowed to move tokens like below function
    // function transferFrom(address sender, address recipient, uint amount) public 
    // onlyApprovedOrSplyt(_from, _to, _value) onlyNonBanned(_from) returns (bool success) {
    //     _transfer(sender, recipient, amount);
    //     _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "Transfer amount exceeds allowance"));
    //     return true;
    // }
    
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    

    // Internal functions
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "Transfer from " + _errZeroAddress);
        require(recipient != address(0), "Transfer to " + _errZeroAddress);
        _beforeTransfer();

        _balances[sender] = _balances[sender].sub(amount, "Transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Approve from " + _errZeroAddress);
        require(spender != address(0), "Approve to " + _errZeroAddress);

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    event Transfer(address indexed sender, address indexed recipient, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}