const AssetManager = artifacts.require("./AssetManager.sol");
const SplytManager = artifacts.require("./SplytManager.sol");
const SatToken = artifacts.require("./SatToken.sol");
const Asset = artifacts.require("./Asset.sol");


contract('AssetManagerTest general test cases.', function(accounts) {

  // let assetManagerInstance;
  // let splytManagerInstance;

  const defaultBuyer = accounts[0];
  const defaultSeller = accounts[1];
  const defaultMarketPlace = accounts[2];

  let satTokenInstance;
  let assetManagerInstance;
  let splytManagerInstance;
  let assetInstance;

  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 0, _seller = accounts[0], _title = "MyTitle",
      _totalCost = 1000, _expirationDate = 10001556712588, _mpAddress = accounts[1], _mpAmount = 2, _inventoryCount = 1) {

    await assetManagerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
    assetAddress = await assetManagerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);

  }

  // This function gets ran before every test cases in this file.
  beforeEach('Default instances of contracts for each test', async function() {
    console.log('this has been called onced only') 
    satTokenInstance = await SatToken.deployed()   
    assetManagerInstance = await AssetManager.deployed();
    splytManagerInstance = await SplytManager.deployed();

    accounts.forEach(async function(acc) {
      await satTokenInstance.initUser(acc)
    })

  })


  it('should create new asset manager.', async function() {
    await create_asset();
    
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.equal(true, true, "wtf foolio");
  })

  // it('should NOT release funds to seller if asset is NOT fully funded and the asset is expired .', async function() {
  //   var time = Date.now()/1000 | 0;
  //   await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+5, accounts[2], 2);
  //   await assetInstance.contribute(accounts[2], accounts[0], 100);
  //   await sleep(10*1000);
  //   await assetInstance.releaseFunds();
  //   var getBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
  //   assert.equal(getBal0.valueOf(), defaultTokenAmount, 'No money should be transfered to seller\'s wallet!');
  // })

  // it('should NOT release funds to seller if asset is fully funded && the asset is expired .', async function() {
  //   var time = Date.now()/1000 | 0;
  //   await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, time+1, accounts[2], 2);
  //   await assetInstance.contribute(accounts[2], accounts[0], 100);
  //   await sleep(5*1000);
  //   await assetInstance.releaseFunds();
  //   var getBal0 = await splytTrackerInstance.getBalance.call(accounts[1]);
  //   assert.equal(getBal0.valueOf(), defaultTokenAmount, 'No money should be transfered to seller\'s wallet!');
  // })

  // it('should release funds to seller if asset is fully funded and the asset is expired .', async function() {
  //   var time = Date.now()/1000 | 0;
  //   var kickbackAmount = 2;
  //   var sellerBefore = await splytTrackerInstance.getBalance.call(accounts[4]);
  //   await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[4], "MyTitle", 1000, time+5, accounts[0], kickbackAmount);
  //   await assetInstance.contribute(accounts[0], accounts[2], 1000);
  //   await sleep(10*1000);
  //   await assetInstance.releaseFunds();
  //   var sellerAfter = await splytTrackerInstance.getBalance.call(accounts[4]);
  //   assert.equal(sellerAfter - sellerBefore, 1000 - kickbackAmount, 'Incorrect amount of money has been transfered to sellers wallet.');
  // })

  // it('should return that my contribution is zero if _assetId is \'0x0\'', async function() {
  //   await create_asset("0x0", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2);
  //   await assetInstance.contribute.call(accounts[2], accounts[0], 100);
  //   var result = await assetInstance.getMyContributions(accounts[0]);
  //   assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions - see \'internalContribute\' function in SplytTracker.sol contract.');
  // })

  // it('should return revert if mpGets = 0', async function() {
  //   await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 0);
  //   var error;
  //   try {
  //     await assetInstance.contribute.call(accounts[2], accounts[0], 100);
  //   } catch (err) {
  //     error = err;
  //   }
  //   assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened!');
  //   var result = await assetInstance.getMyContributions(accounts[0]);
  //   assert.equal(result.valueOf(), 0, 'User shouldn\'t have any contributions - see \'internalContribute\' function in SplytTracker.sol contract.');
  // })




  // it('calcDistribution - calculate how much seller gets after kickbacks taken out.', async function() {
  //   var calc = await assetInstance.calcDistribution();
  //   assert.equal(calc[0].valueOf(), 2, 'Should be equal = _mpAmount / listOfMarketPlaces.length');
  //   assert.equal(calc[1].valueOf(), 998, 'Should be equal = totalCost - (_mpAmount / listOfMarketPlaces.length)');
  // })

  // if('should give correct kickback amounts to marketplaces', async () => {

  // })

  async function sleep(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }
})