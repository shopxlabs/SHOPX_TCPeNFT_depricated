var SplytManager = artifacts.require("./SplytManager.sol");

contract('SplytManager', function(accounts) {

  var splytManagerInstance;

  it('should return a valid address after deploying splytmanager', async function() {
        
    splytManagerInstance = await SplytManager.deployed()
    console.log('splytmanager address: ' + SplytManager.address)
    assert.notEqual(splytManagerInstance, 0x0, 'SplytManager address is 0x0')

    return true;
  })
  
  // it('should be emitting events upon successful asset creation', function() {
  //   return true;
  // })


})