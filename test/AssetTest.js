var Asset = artifacts.require("./Asset.sol");
var SplytTracker = artifacts.require("./SplytTracker.sol")

contract('AssetTest general test cases.', function(accounts) {

  var assetAddress;
  var splytTrackerInstance;
  var assetInstance;
  var assetCost = 1000;

  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 1, _seller = accounts[1], _title = "MyTitle",
                              _totalCost = 1000, _expirationDate = 10001556712588, _mpAddress = accounts[2], _mpAmount = 2){
    splytTrackerInstance = await SplytTracker.deployed();
    await splytTrackerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount);
    assetAddress = await splytTrackerInstance.getAddressById(_assetId);
    console.log('assetAddress is: ', assetAddress.valueOf());
    assetInstance = await Asset.at(assetAddress);
  }

  beforeEach('Deploying asset contract. ', async function() {

    await create_asset();
  })

  it('should release funds to seller if listing is fully funded and the listing is expired .', async function() {
    var time = Date.now()/1000 | 0;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+1, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 1000);
    sleep(10*1000);
    await assetInstance.releaseFunds();
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
    console.log('getBal0: ', getBal0.valueOf());
    assert.equal(getBal0.valueOf(), 1000, 'Incorrect amount of money has been transfered to sellers wallet.');
  })

  it('should return that my contribution is zero if _assetId is \'0x0\'', async function() {
    await create_asset("0x0", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    var result = await assetInstance.getMyContributions(accounts[0]);
    console.log('result is: ', result.valueOf());
    assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions - see \'internalContribute\' function in SplytTracker.sol contract.');
  })

  it('should tell me my contributions && it should be zero.', async function() {
    var result = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions.');
  })

  it('should be able to contribute partial cost into fractional asset.', async function() {
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[0]);
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[0]);
    assert.equal(getBal0-getBal, 100, 'Money were not withdrawn from contributor\'s account.');
  })

  it('buyer is able to contribute full cost into fractional asset.', async function() {
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var myContributions = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(myContributions, assetCost, 'User should have contributions.');
  })

  it('proper amount of money was withdrawn from buyer\'s account after contributing into fractional asset.', async function() {
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[0]);
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[0]);
    assert.equal(getBal0-getBal, assetCost, 'Incorrect amount of money was withdrawn from contributor\'s account.');
  })

  it('proper amount of money was withdrawn from buyer\'s account after contributing into NOT fractional asset.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[0]);
    var assetInstance = await Asset.at(assetAddress);
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[0]);
    assert.equal(getBal0-getBal, assetCost, 'Incorrect amount of money was withdrawn from contributor\'s account.');
  })

  it('seller gets full cost of NOT fractional asset .', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var getSellerBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
    var assetInstance = await Asset.at(assetAddress);
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var getSellerBal1 = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getSellerBal1-getSellerBal0, assetCost, 'Incorrect amount of money seller got from contributor.');
  })

  it('user is NOT able to contribute if date is expired.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 1494694079, accounts[2], 2);
    var isOpenForContr = await assetInstance.isOpenForContribution(1);
    console.log('isOpenForContr is: ', isOpenForContr);
    assert.equal(isOpenForContr, false, 'I shouldn\'t be able to contribute due to expired date.');
  })

  it('user is NOT able to contribute if total cost has been exceeded.', async function() {
    var isOpenForContr = await assetInstance.isOpenForContribution(1001);
    assert.equal(isOpenForContr, false, 'I shouldn\'t be able to contribute due to exceeded total cost.');
  })

  it('asset is open for contribution.', async function() {
    var isOpenForContr = await assetInstance.isOpenForContribution(999);
    assert.equal(isOpenForContr, true, 'I should be able to contribute.');
  })

  it('user is able to contribute (2 attemps to contribute).', async function() {
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    var isOpenForContr = await assetInstance.isOpenForContribution(899);
    assert.equal(isOpenForContr, true, 'I should be able to contribute.');
  })

  it('user should NOT be able to contribute (2 attemps to contribute) if total cost has been exceeded.', async function() {
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    var isOpenForContr = await assetInstance.isOpenForContribution(999);
    assert.equal(isOpenForContr, false, 'I should be able to contribute.');
  })

  it('user should NOT be able to contribute (2 attemps to contribute) if date is expired.', async function() {
    var time = Date.now()/1000 | 0;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+1, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    sleep(10*1000);
    var isOpenForContr = await assetInstance.isOpenForContribution(899);
    assert.equal(isOpenForContr, false, 'I shouldn\'t be able to contribute if date is expired.');
  })

  it('isFunded returns true if asset has been fully funded.', async function() {
    await assetInstance.contribute(accounts[2], accounts[0], 1000);
    var isFund = await assetInstance.isFunded();
    assert.equal(isFund, true, 'Asset should be fully funded.');
  })

  it('isFunded returns false if asset has NOT been fully funded.', async function() {
    await assetInstance.contribute(accounts[2], accounts[0], 999);
    var isFund = await assetInstance.isFunded();
    assert.equal(isFund, false, 'Asset should NOT be fully funded.');
  })

  it('isFractional returns true if asset is fractional.', async function() {
    var isFund = await assetInstance.isFractional();
    assert.equal(isFund, true, 'Asset should be fractional.');
  })

  it('isFractional returns false if asset is NOT fractional.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var isFund = await assetInstance.isFractional();
    assert.equal(isFund, false, 'Asset should NOT be fractional.');
  })

  it('calcDistribution - calculate how much seller gets after kickbacks taken out.', async function() {
    var calc = await assetInstance.calcDistribution();
    console.log('calc[1] is: ', calc[1].valueOf());
    console.log('calc[0]: ', calc[0].valueOf());
    assert.equal(calc[0].valueOf(), 2, 'Should be equal = _mpAmount / listOfMarketPlaces.length');
    assert.equal(calc[1].valueOf(), 998, 'Should be equal = totalCost - (_mpAmount / listOfMarketPlaces.length)');
  })

  function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
      if ((new Date().getTime() - start) > milliseconds){
        break;
      }
    }
  }
})