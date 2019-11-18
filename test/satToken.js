var SatToken = artifacts.require("./SatToken.sol");

contract('SatToken', function(accounts) {

  it('should give any user 20500 tokens', function() {
    return SatToken.deployed().then(function(instance) {
      instance.balanceOf(accounts[0]).then(function(balance) {
        assert.equal(balance.valueOf(), 20500, '20500 wasn\'t in the first account');
      })
    })
  })

  it('should transfer 200 tokens from my account to another account', function() {
    return SatToken.deployed().then(function(instance) {
      instance.transfer(accounts[1], 200).then(function() {
        instance.balanceOf(accounts[1]).then(function(balance) {
          assert.equal(balance.valueOf(), 200, 'user to didn\'t recieve tokens')
        })
      })
    })
  })
})