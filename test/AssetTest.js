const Asset = artifacts.require("./Asset.sol");
const SplytTracker = artifacts.require("./SplytTracker.sol")
const SatToken = artifacts.require("./SatToken.sol")
const Stake = artifacts.require("./Stake.sol")


contract('AssetTest general test cases.', function(accounts) {

  let assetAddress;
  let splytTrackerInstance;
  let assetInstance;
  let stakeInstance;
  const assetCost = 1000;
  let satTokenInstance;
  const defaultTokenAmount = 205000000;

  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 1, _seller = accounts[1], _title = "MyTitle",
      _totalCost = 1000, _expirationDate = 10001556712588, _mpAddress = accounts[2], _mpAmount = 2){
    splytTrackerInstance = await SplytTracker.deployed();
    await splytTrackerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount);
    assetAddress = await splytTrackerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);
    stakeInstance = await Stake.deployed();
  }

  // This function gets ran before every test cases in this file.
  beforeEach('Deploying asset contract. ', async function() {
    // reset all account's token balance to 20500 before running each test except account[5]
    satTokenInstance = await SatToken.deployed()
    accounts.forEach(async function(acc) {
      if(acc != accounts[5]){
        await satTokenInstance.initUser(acc)
      }
    })
  })

  it('should NOT release funds to seller if asset is NOT fully funded and the asset is NOT expired .', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);

    await assetInstance.contribute(accounts[2], accounts[0], 100);
    await assetInstance.releaseFunds();
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getBal0.valueOf(), defaultTokenAmount, 'No money should be transfered to seller\'s wallet!');
  })

  it('should NOT release funds to seller if asset is NOT fully funded and the asset is expired .', async function() {
    var time = Date.now()/1000 | 0;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+5, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    await sleep(10*1000);
    await assetInstance.releaseFunds();
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getBal0.valueOf(), defaultTokenAmount, 'No money should be transfered to seller\'s wallet!');
  })

  it('should NOT release funds to seller if asset is fully funded && the asset is expired .', async function() {
    var time = Date.now()/1000 | 0;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+1, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    await sleep(5*1000);
    await assetInstance.releaseFunds();
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getBal0.valueOf(), defaultTokenAmount, 'No money should be transfered to seller\'s wallet!');
  })

  it('should release funds to seller if asset is fully funded and the asset is expired .', async function() {
    var time = Date.now()/1000 | 0;
    var kickbackAmount = 2;
    var sellerBefore = await splytTrackerInstance.getBalance.call(accounts[4]);
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[4], "MyTitle", 1000, time+5, accounts[0], kickbackAmount);
    await assetInstance.contribute(accounts[0], accounts[2], 1000);
    await sleep(10*1000);
    await assetInstance.releaseFunds();
    var sellerAfter = await splytTrackerInstance.getBalance.call(accounts[4]);
    assert.equal(sellerAfter - sellerBefore, 1000 - kickbackAmount, 'Incorrect amount of money has been transfered to sellers wallet.');
  })

  it('should return that my contribution is zero if _assetId is \'0x0\'', async function() {
    await create_asset("0x0", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute.call(accounts[2], accounts[0], 100);
    var result = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions - see \'internalContribute\' function in SplytTracker.sol contract.');
  })

  it('should return revert if mpGets = 0', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 0);
    var error;
    try {
      await assetInstance.contribute.call(accounts[2], accounts[0], 100);
    } catch (err) {
      error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
    var result = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions - see \'internalContribute\' function in SplytTracker.sol contract.');
  })

  it('user is not able to contribute if asset is not open for contribution.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var error;
    try {
      await assetInstance.contribute.call(accounts[2], accounts[0], 1001);
    } catch (err) {
      error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
    var result = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions.');
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
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var myContributions = await assetInstance.getMyContributions(accounts[0]);
    assert.equal(myContributions, assetCost, 'User should have contributions.');
  })

  it('proper amount of money was withdrawn from buyer\'s account after contributing into fractional asset.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var getBal0 = await splytTrackerInstance.getBalance.call(accounts[0]);
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[0]);
    assert.equal(getBal0-getBal, assetCost, 'Incorrect amount of money was withdrawn from contributor\'s account.');
  })

  it('buyer is NOT able to contribute because of not having money.', async function() {
    var error;
    try {
      await assetInstance.contribute(accounts[2], accounts[4], assetCost);
    } catch (err) {
      error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
    var myContributions = await assetInstance.getMyContributions(accounts[4]);
    assert.equal(myContributions, 0, 'User should NOT have contributions because of not having money.');
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
    var kickbackAmount = 2;
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], kickbackAmount);
    var getSellerBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
    var assetInstance = await Asset.at(assetAddress);
    await assetInstance.contribute(accounts[2], accounts[0], assetCost);
    var getSellerBal1 = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getSellerBal1-getSellerBal0, assetCost - kickbackAmount, 'Incorrect amount of money seller got from contributor.');
  })

  it('user is NOT able to contribute if date is expired.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 1494694079, accounts[2], 2);
    var isOpenForContr = await assetInstance.isOpenForContribution(1);
    assert.equal(isOpenForContr, false, 'I shouldn\'t be able to contribute due to expired date.');
  })

  it('user is NOT able to contribute if total cost has been exceeded.', async function() {
    var isOpenForContr = await assetInstance.isOpenForContribution(1001);
    assert.equal(isOpenForContr, false, 'I shouldn\'t be able to contribute due to exceeded total cost.');
  })

  it('asset is open for contribution.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var isOpenForContr = await assetInstance.isOpenForContribution(999);
    assert.equal(isOpenForContr, true, 'I should be able to contribute.');
  })

  it('user is able to contribute.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 100);
    var isOpenForContr = await assetInstance.isOpenForContribution(899);
    assert.equal(isOpenForContr, true, 'I should be able to contribute.');
  })

  it('user should NOT be able to contribute (2 attemps to contribute) if total cost has been exceeded.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute(accounts[0], accounts[0], 100);
    await sleep(5*1000);
    var isOpenForContr = await assetInstance.isOpenForContribution(999);
    assert.equal(isOpenForContr, false, 'I should be able to contribute.');
  })

  it('user should NOT be able to contribute (2 attemps to contribute) if date is expired', async function() {
    var time = parseInt(Date.now()/1000);
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+1, accounts[2], 2);
    //await assetInstance.contribute(accounts[2], accounts[0], 100);
    await sleep(5*1000);
    try {
      await assetInstance.contribute(accounts[2], accounts[0], 100);
    } catch (e) {
      if(e.toString().indexOf('revert') === -1) {
        return false;
      } else {
        return true;
      }

    }
  })

  it('isFunded returns true if asset has been fully funded.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 1000);
    var isFund = await assetInstance.isFunded();
    assert.equal(isFund, true, 'Asset should be fully funded.');
  })

  it('isFunded returns false if asset has NOT been fully funded.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    await assetInstance.contribute(accounts[2], accounts[0], 999);
    var isFund = await assetInstance.isFunded();
    assert.equal(isFund, false, 'Asset should NOT be fully funded.');
  })

  it('isFractional returns true if asset is fractional.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
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
    assert.equal(calc[0].valueOf(), 2, 'Should be equal = _mpAmount / listOfMarketPlaces.length');
    assert.equal(calc[1].valueOf(), 998, 'Should be equal = totalCost - (_mpAmount / listOfMarketPlaces.length)');
  })

  it('stack tokens after asset creation, asset is fractional', async function() {
    await create_asset();
    var isFractional = await assetInstance.isFractional();
    assert.equal(isFractional, true, 'Asset should be fractional');
    var getBal = await splytTrackerInstance.getBalance.call(accounts[1]);
    var stakeTokens = await stakeInstance.calculateStakeTokens(assetCost);
    assert.equal(getBal, defaultTokenAmount - stakeTokens, 'Should stack tokens according to percentage');
  })

  it('stack tokens after asset creation, asset is NOT fractional', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
    var isFractional = await assetInstance.isFractional();
    assert.equal(isFractional, false, 'Asset should be fractional');
    var getBal = await splytTrackerInstance.getBalance.call(accounts[1]);
    var stakeTokens = await stakeInstance.calculateStakeTokens(assetCost);
    assert.equal(getBal, defaultTokenAmount - stakeTokens, 'Should stack tokens according to percentage');
  })

  it('stack 0 tokens if assetCost = 0', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 0, 10001556712588, accounts[2], 0);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getBal, defaultTokenAmount, 'Should not stack tokens');
  })

  it('should revert asset creation && stack if seller does not have a money', async function(){
    var error;
    try {
      await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[5], "MyTitle", 1000, 10001556712588, accounts[2], 1);
    } catch(err) {
      error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
    var getBal = await splytTrackerInstance.getBalance.call(accounts[5]);
    assert.equal(getBal, 0, 'Should not stack tokens');
  })

  it('should revert asset creation && not stack money if assetCost is negative', async function(){
    var error;
    try {
      await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", -1000, 10001556712588, accounts[2], 1);
    } catch(err) {
      error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
    var getBal = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getBal, defaultTokenAmount, 'Should not stack tokens');
  })

  it('should revert asset creation if stakeTokens > sellersBal', async function(){
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 10, 10001556712588, accounts[5], 10);
    await assetInstance.contribute(accounts[5], accounts[2], 10);
    var getBal5 = await splytTrackerInstance.getBalance.call(accounts[5]);
    var stakeTokens = await stakeInstance.calculateStakeTokens(assetCost);
    assert.equal(stakeTokens > getBal5, true, 'stakeTokens should be more than balance');
    var error;
    try {
      await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[5], "MyTitle", assetCost, 10001556712588, accounts[1], 1);
    } catch(err) {
      error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
  })

  // if('should give correct kickback amounts to marketplaces', async () => {

  // })

  async function sleep(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }
})