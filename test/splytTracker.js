var SplytTracker = artifacts.require("./SplytTracker.sol");

contract('SplytTracker', function(accounts) {

  var splytTrackerInstance;
  it('should be able to create an asset using valid parameters', function() {
    return SplytTracker.deployed().then(function(instance){
      splytTrackerInstance = instance;
      instance.createAsset(
        "0x31f2ae92057a7123ef0e490a",
        111,
        accounts[1],
        "Test asset",
        1000,
        1556712588,
        accounts[2],
        4
      ).then(function() {
        splytTrackerInstance.getAddressById("0x31f2ae92057a7123ef0e490b").then(function(assetAddr) {
          assert.equal(assetAddr, '0x0000000000000000000000000000000000000000', 'Asset contract deployment failed')
        })
      })
    })
  })
  
  it('should be emitting events upon successful asset creation', function() {
    return true;
  })

  it('should be emitting events upon successful contritution(fractional || !)', function() {
    return true;
  })

  it('should NOT be able to call internalContribute function from outside', function() {
    return true;
  })

  if('should NOT be able to call internalRedeemFunds function from outside', function() {
    return true;
  })

  if('should be emitting error events upon failed token transfers for internalRedeemFunds function', function() {
    return true;
  })

  it('should be emitting error events upon failed token transfers for internalRedeemFunds', function() {
    return true;
  })

})