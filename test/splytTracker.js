var SplytTracker = artifacts.require("./SplytTracker.sol");

contract('SplytTracker', function(accounts) {

  var splytTrackerInstance;
  it('should be able to create an asset using valid parameters', function(){
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
  


})