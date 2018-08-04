var SplytManager = artifacts.require("./SplytManager.sol");

contract('SplytManager', function(accounts) {

  var splytManagerInstance;

  it('should be able to create an asset using valid parameters', async function() {
        
    splytManagerInstance = await SplytManager.deployed()
    await splytManagerInstance.createAsset(
        "0x31f2ae92057a7123ef0e490a",
        111,
        accounts[1],
        "Test asset",
        1000,
        1556712588,
        accounts[2],
        4,
        1
      )
    return true;
  })
  
  it('should be emitting events upon successful asset creation', function() {
    return true;
  })


})