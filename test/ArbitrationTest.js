const Asset = artifacts.require("./Asset.sol");
const SplytTracker = artifacts.require("./SplytTracker.sol")
const SatToken = artifacts.require("./SatToken.sol")

contract('Arbitration general tests.', function(accounts) {

  let splytTrackerInstance;
  let assetInstance;
  let satTokenInstance;


  async function create_asset(_assetId, _term, _seller, _title, _totalCost, _expirationDate , _mpAddress, _mpAmount){
    splytTrackerInstance = await SplytTracker.deployed();
    await splytTrackerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount);
    assetAddress = await splytTrackerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);
  }

  // This function gets ran before every test cases in this file.
    beforeEach('Deploying asset contract. ', async function() {
      // reset all account's token balance to 20500 before running each test
       satTokenInstance = await SatToken.deployed()
       accounts.forEach(async function(acc) {
         if(acc != accounts[4]){
           await satTokenInstance.initUser(acc)
         }
      })
    })

  it('should successfully arbitrate fractional asset.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
    var isFractional = await assetInstance.isFractional();
    assert.equal(isFractional, true, "Asset should be fractional");
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
  })

  it('should successfully arbitrate NOT fractional asset.', async function() {
     await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
     var isFractional = await assetInstance.isFractional();
     assert.equal(isFractional, false, "Asset should not be fractional");
     var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
     assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
   })

  it('should NOT open for contribution if fractional asset is arbitrated.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isContributed= await assetInstance.isOpenForContribution(1);
    assert.equal(isContributed, false, "Asset should be closed for contribution");
  })

  it('should NOT open for contribution if NOT fractional asset is arbitrated.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isContributed= await assetInstance.isOpenForContribution(1);
    assert.equal(isContributed, false, "Asset should be closed for contribution");
  })

  it('should successfully arbitrate asset by anyone', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[3]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
  })

  xit('should fail if seller arbitrates asset', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
    var error;
    try{
        await assetInstance.arbitrate("SPAM", accounts[1]);
    }catch(err) {
            error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  xit('should fail arbitrate if asset is expired', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 1494694079, accounts[2], 2);
    var error;
    try{
        await assetInstance.arbitrate("SPAM", accounts[2]);
    }catch(err) {
        error = err;
    }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  it('should successfully arbitrate if balance == 0  and  initialStakeAmount == 0',async function() {
     await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1, 10001556712588, accounts[4], 2);
     var balance = await splytTrackerInstance.getBalance.call(accounts[4]);
     assert.equal(balance, 0, "User should not have enough money to arbitrate");
     var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[4]);
     assert.equal(isArbitrate.receipt.status, 1, "Asset should  be arbitrated");
  })

  it('should fail arbitrate if user has not enough funds', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[4], 2);
    var balance = await splytTrackerInstance.getBalance.call(accounts[4]);
    assert.equal(balance, 0, "User should not have enough money to arbitrate");
    var error;
    try {
          await assetInstance.arbitrate("SPAM", accounts[4]);
        } catch (err) {
          error = err;
        }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  it('should fail if NOT seller disputes reported spam', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1, 10001556712588, accounts[4], 2);
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[4]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var error;
    try {
          await assetInstance.disputeReportedSpam(accounts[2]);
        } catch (err) {
          error = err;
        }
    assert.equal(error, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })
})