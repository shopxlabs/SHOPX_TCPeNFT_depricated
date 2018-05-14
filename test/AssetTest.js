var Asset = artifacts.require("./Asset.sol");
var SplytTracker = artifacts.require("./SplytTracker.sol")

contract('AssetTest', function(accounts) {

  var assetAddress;

  beforeEach('deploying asset contract', async function() {

    var splytTrackerInstance = await SplytTracker.deployed();
    var result = await splytTrackerInstance.createAsset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    assetAddress = await splytTrackerInstance.getAddressById("0x31f2ae92057a7123ef0e490a");
    console.log('asset address from before each', assetAddress);

  })

  it('should tell me my contributions && it should be zero', async function() {
    console.log('asset address from it should', assetAddress);
    var assetInstance = await Asset.at(assetAddress);
    var result = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(result.valueOf(), 0, 'I shouldn\'t have any contributions');
  })
  
  it('should be able to contribute', async function() {
    var assetInstance = await Asset.at(assetAddress);
    var result = await assetInstance.contribute(accounts[2], accounts[0], 100);
    var myContributions = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(myContributions, 100, 'I shouldn\'t have any contributions');
  })

})