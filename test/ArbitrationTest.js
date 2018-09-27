const Asset = artifacts.require("./Asset.sol");
const SplytTracker = artifacts.require("./SplytTracker.sol")
const SatToken = artifacts.require("./SatToken.sol")
const Stake = artifacts.require("./Stake.sol")

contract('Arbitration general tests.', function(accounts) {

  let splytTrackerInstance;
  let assetInstance;
  let satTokenInstance;
  let stakeInstance;
  let totalCost = 100;
  const defaultTokenAmount = 205000000;


  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 1, _seller = accounts[1], _title = "MyTitle",
    _totalCost = totalCost, _expirationDate = 10001556712588, _mpAddress = accounts[2], _mpAmount = 2){
    splytTrackerInstance = await SplytTracker.deployed();
    await splytTrackerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount);
    assetAddress = await splytTrackerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);
    stakeInstance = await Stake.deployed();
  }

  // This function gets ran before every test cases in this file.
    beforeEach('Deploying asset contract. ', async function() {
      // reset all account's token balance to 205000000 before running each test except account[4]
       satTokenInstance = await SatToken.deployed()
       accounts.forEach(async function(acc) {
         if(acc != accounts[4]){
           await satTokenInstance.initUser(acc)
         }
      })
    })

  it('should successfully arbitrate fractional asset.', async function() {
    await create_asset();
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
    await create_asset();
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
    await create_asset();
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[3]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
  })

  //bug, seller(owner) can not perform arbitrate asset. Bug should be fixed.
  xit('should fail if seller arbitrates asset', async function() {
    await create_asset();
    var isArbitrate = await handleVMException(assetInstance.arbitrate, ["SPAM", accounts[1]]);
    assert.equal(isArbitrate, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  // bug, user can not perform arbitrate if asset is expired. Bug should be fixed.
  xit('should fail arbitrate if asset is expired', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 1494694079, accounts[2], 2);
    var isArbitrate = await handleVMException(assetInstance.arbitrate, ["SPAM", accounts[2]]);
    assert.equal(isArbitrate, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  it('should successfully arbitrate if balance == 0  and  initialStakeAmount == 0',async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1, 10001556712588, accounts[4], 2);
    var balance = await splytTrackerInstance.getBalance.call(accounts[4]);
    assert.equal(balance, 0, "Balance of user should be 0");
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[4]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should  be arbitrated");
  })

  it('should fail arbitrate if user has not enough funds', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[4], 2);
    var balance = await splytTrackerInstance.getBalance.call(accounts[4]);
    assert.equal(balance, 0, "User should not have enough money to arbitrate");
    var isArbitrate = await handleVMException(assetInstance.arbitrate, ["SPAM", accounts[4]]);
    assert.equal(isArbitrate, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  //bug, more then one user can not arbitrate the same asset
  xit('should fail arbitrate if more than one user performs arbitration for the same asset at the same time', async function() {
    await create_asset();
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isArbitrateSecond = await handleVMException(assetInstance.arbitrate, ["SPAM", accounts[3]]);
    assert.equal(isArbitrateSecond, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  //bug, the same reporter can not perform arbitration more than once in a row
  xit('should fail if the same user performs arbitration more than once in a row', async function() {
    await create_asset();
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isArbitrateAgain = await handleVMException(assetInstance.arbitrate, ["SPAM", accounts[2]]);
    assert.equal(isArbitrateAgain, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  it('should fail if NOT seller disputes reported spam', async function() {
    await create_asset();
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[3]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isDispute = await handleVMException(assetInstance.disputeReportedSpam, [accounts[2]]);
    assert.equal(isDispute, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  it('should successfully if seller disputes arbitrated asset', async function() {
    await create_asset();
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isDispute = await assetInstance.disputeReportedSpam(accounts[1]);
    assert.equal(isDispute.receipt.status, 1, "Asset should be disputed");
  })

  it('should fail disputing if seller has not enough funds', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 100, 10001556712588, accounts[4], 100);
    await assetInstance.contribute(accounts[4], accounts[1], 100);

    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[4], "MyTitle2", 100, 10001556712588, accounts[1], 50);
    await assetInstance.contribute(accounts[1], accounts[4], 96);
    var balance = await splytTrackerInstance.getBalance.call(accounts[4]);
    assert.equal(balance, 0, "User should not have money");
    await assetInstance.arbitrate("SPAM", accounts[1]);
    var isDispute = await handleVMException(assetInstance.disputeReportedSpam, [accounts[4]]);
    assert.equal(isDispute, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  // bug, seller(owner) can not perform disputing until asset is not arbitrated by reporter. Bug should be fixed
  xit('should fail disputing if asset is not arbitrated', async function() {
    await create_asset();
    var isDispute = await handleVMException(assetInstance.disputeReportedSpam, [accounts[1]]);
    assert.equal(isDispute, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  //bug, seller can not perform disputing more than once in a row. Bug should be fixed
  xit('should fail if seller try to perform disputing more than once in a row', async function() {
    await create_asset();
    await assetInstance.arbitrate("SPAM", accounts[2]);
    var isDispute = await assetInstance.disputeReportedSpam(accounts[1]);
    assert.equal(isDispute.receipt.status, 1, "Asset should be disputed");
    isDisputeAgain = await handleVMException(assetInstance.disputeReportedSpam, [accounts[1]]);
    assert.equal(isDisputeAgain, 'Error: VM Exception while processing transaction: revert', 'Revert error has not happened');
  })

  it('should successfully arbitrate again after disputing asset by seller', async function() {
    await create_asset();
    var isArbitrate = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrate.receipt.status, 1, "Asset should be arbitrated");
    var isDispute = await assetInstance.disputeReportedSpam(accounts[1]);
    assert.equal(isDispute.receipt.status, 1, "Asset should be disputed")
    var isArbitrateAgain = await assetInstance.arbitrate("SPAM", accounts[2]);
    assert.equal(isArbitrateAgain.receipt.status, 1, "Asset should be arbitrated again");
  })

  it('should successfully release funds from reporter after asset arbitration', async function() {
    await create_asset();
    var getBalBefore = await splytTrackerInstance.getBalance.call(accounts[2]);
    await assetInstance.arbitrate("SPAM", accounts[2]);
    var getBalAfter = await splytTrackerInstance.getBalance.call(accounts[2]);
    var stakeTokens = await stakeInstance.calculateStakeTokens(totalCost);
    assert.equal(getBalBefore - getBalAfter, stakeTokens, "Money should be charged from reporter");
  })

  it('should successfully release funds from seller after disputing', async function() {
    await create_asset();
    await assetInstance.arbitrate("SPAM", accounts[2]);
    var getBalBefore = await splytTrackerInstance.getBalance.call(accounts[1]);
    await assetInstance.disputeReportedSpam(accounts[1]);
    var getBalAfter = await splytTrackerInstance.getBalance.call(accounts[1]);
    var stakeTokens = await stakeInstance.calculateStakeTokens(totalCost);
    assert.equal(getBalBefore - getBalAfter, stakeTokens, "Money should be charged from seller");
  })

  it('should stack 0 from reporter after arbitration if totalCost == 0', async function() {
    var totalCost = 0;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", totalCost, 10001556712588, accounts[2], 1);
    await assetInstance.arbitrate("SPAM", accounts[2]);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[2]);
    assert.equal(getBal, defaultTokenAmount, "Money should not be charged");
    var stakeTokens = await stakeInstance.calculateStakeTokens(totalCost);
    assert.equal(stakeTokens, 0, "Should stack 0 SAT tokens");
  })

   it('should stack 0 from seller after disputing if totalCost == 0', async function() {
    var totalCost = 0;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", totalCost, 10001556712588, accounts[2], 1);
    await assetInstance.arbitrate("SPAM", accounts[2]);
    await assetInstance.disputeReportedSpam(accounts[1]);
    var getBal = await splytTrackerInstance.getBalance.call(accounts[1]);
    assert.equal(getBal, defaultTokenAmount, "Money should not be charged");
    var stakeTokens = await stakeInstance.calculateStakeTokens(totalCost);
    assert.equal(stakeTokens, 0, "Should stack 0 SAT tokens");
  })

  it('should successfully if seller dispute NOT fractional asset', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 0, accounts[1], "MyTitle", 100, 10001556712588, accounts[2], 2);
    var isFractional = await assetInstance.isFractional();
    assert.equal(isFractional, false, "Asset should not be fractional");
    await assetInstance.arbitrate("SPAM", accounts[2]);
    var isDispute = await assetInstance.disputeReportedSpam(accounts[1]);
    assert.equal(isDispute.receipt.status, 1, "Asset should be disputed");
  })

  it('should successfully dispute if balance == 0  and  initialStakeAmount == 0', async function() {
    var totalCost = 1;
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[4], "MyTitle", totalCost, 10001556712588, accounts[1], 2);
    await assetInstance.arbitrate("SPAM", accounts[1]);
    var getBal4 = await splytTrackerInstance.getBalance.call(accounts[4]);
    assert.equal(getBal4, 0, "Balance should be equal 0");
    var initialStakeAmount = await stakeInstance.calculateStakeTokens(totalCost);
    assert.equal(initialStakeAmount, 0, "Initial stake amount should equal 0");
    var isDispute = await assetInstance.disputeReportedSpam(accounts[4]);
    assert.equal(isDispute.receipt.status, 1, "Asset should be disputed");
  })

  async function handleVMException(method, inputs) {
    try {
      return await method(...inputs);
    } catch (err) {
      return err;
    }
  }
})