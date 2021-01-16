// SPDX-License-Identifier: MIT
pragma solidity >=0.7.4;

import "./ERC20.sol";
import "./SafeMath.sol";

// Splyt logic on top of standard erc20 contract
contract SatToken is ERC20, Owned {
    using SafeMath for uint256;

    uint _version;
    bool _paused;
    uint256 _tokenPerEth;
    
    constructor (uint version, uint256 tokenPerEth) public {
        _version = version;
        _paused = true;
        _tokenPerEth = tokenPerEth;
    }

    
    function getEthBalance() public view returns (uint) {
        return address(this).balance;
    }

    function pause(bool pauseUnpause) public onlyOwner returns (bool) {
        _paused = pauseUnpause;
    }

    // This function will trade your ether with sat tokens for you.
    // the only way to attain sat tokens
    function buyTokenFromEth() public payable returns(bool) {
        _beforeTransfer();
        // Accepting minimum 1 ether per tx in ICO phase
        require(msg.value > 1000000000000000000, "Accepting minimum 1 eth per tx in ICO phase");
        
        uint256 eth = msg.value.div(1000000000000000000);
        _mint(msg.sender, msg.value.mul(_tokenPerEth));
        
    }
    //Splyt related logic to allow based on platform behaviour
    // Might not be needed if splyt will use allowance style 
    // modifier onlyApprovedOrSplyt(address _from, address _to, uint _value) {
    //     if(allowed[_from][_to] <= _value || msg.sender == trackerAddress)
    //         _;
    // }
    
    function _beforeTransfer() internal virtual override {
        require(paused, "Transfers are paused");
    }
    
    fallback() external payable {
        msg.sender.transfer(msg.value);
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "Mint to " + _errZeroAddress);

        _beforeTransfer(address(0), account, amount);

        _totalMinted = _totalMinted.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    modifier onlyNonBanned(address _from) {
        if(banned[_from][msg.sender] == false)
            _;
    }
}

