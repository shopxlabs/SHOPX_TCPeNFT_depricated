const ReputationManager = artifacts.require("./ReputationManager.sol");

const SatToken = artifacts.require("./SatToken.sol");
const Asset = artifacts.require("./Asset.sol");


contract('ReputationManagerTest general test cases.', function(accounts) {

  const defaultBuyer = accounts[0];
  const defaultSeller = accounts[1];
  const defaultMarketPlace = accounts[2];
  const defaultArbitrator = accounts[3];
  
  const defaultPrice = 1000;
  const defaultExpDate = (new Date().getTime() / 1000) + 60;
  const defaultAssetId = "0x31f2ae92057a7123ef0e490a";
  const defaultArbitrationId = "0x31f2ae92057a7123ef0e490a";

  const defaultInventoryCount = 2;

  let reputationManagerInstance;


  //Instantiate the contracts
  init();

  // async function create_asset(_assetId = defaultAssetId, _term = 0, _seller = defaultSeller, _title = "MyTitle",
  //     _totalCost = defaultPrice, _expirationDate = defaultExpDate, _mpAddress = defaultMarketPlace, _mpAmount = 2, _inventoryCount = defaultInventoryCount) {

  //   await assetManagerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
  //   assetAddress = await assetManagerInstance.getAddressById(_assetId);
  //   assetInstance = await Asset.at(assetAddress);

  // }

  //Instantiate it only once
  async function init() {
    
    console.log('defaultBuyer wallet: ' + defaultBuyer);
    console.log('defaulSeller wallet: ' + defaultSeller);
    console.log('defaultMarketPlace wallet: ' + defaultMarketPlace);

    reputationManagerInstance = await ReputationManager.deployed()    
  }

  
  // This function gets ran before every test cases in this file.
  beforeEach('Default instances of contracts for each test', async function() {
    //reinitalize each account balance
    // accounts.forEach(async function(acc) {
    //   await satTokenInstance.initUser(acc)
    // })

    // let balance = await satTokenInstance.balanceOf(defaultBuyer)
    // console.log('defaultBuyer balance:' + balance)

    // balance = await satTokenInstance.balanceOf(defaultSeller)
    // console.log('defaultSeller balance:' + balance)

  })


  it('should be new reputation manager contract successfully!', async function() {    
    let reputationManagerAddress = reputationManagerInstance.address;
    // console.log('reputationManager address: ' + reputationManagerAddress)
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(reputationManagerAddress, 0x0, "ReputationManager manager has not been deployed!");
  })

  it('should be create a successfull 5 star review. Average should be 5!', async function() {
    await reputationManagerInstance.createReview(defaultSeller, 5);
    let rating = await reputationManagerInstance.getRatingByWallet(defaultSeller);
    // console.log('rating: ' + rating);
    assert.equal(rating, 500, "Rating should be 500(5.00)");
  })

  it('should be create a successfull 3 star review!. Average should be 4', async function() {
    await reputationManagerInstance.createReview(defaultSeller, 3);
    let averageRating = await reputationManagerInstance.getRatingByWallet(defaultSeller);
    // console.log('rating: ' + averageRating);
    assert.equal(averageRating, 400, "Rating should be 400(4.00)");
  })

  
  it('should be create a successfull 3 star review! Average should be 3.66', async function() {
    await reputationManagerInstance.createReview(defaultSeller, 3);
    let averageRating = await reputationManagerInstance.getRatingByWallet(defaultSeller);
    // console.log('rating: ' + averageRating);
    assert.equal(averageRating, 366, "Rating should be 366(3.66)");
  })

 //  it('should be status 2=IN_ARBITRATION after reporter creates an arbitration!', async function() {
    
 //    let status = await assetInstance.status();

 //    // console.log('asset status after being reported:: ' + status);
 //    assert.equal(status, 2, "Status is not in IN_ARBITRATION!");
 //  })


 //  it('should not be able to purchase order a asset in status 2=IN_ARBITRATION!', async function() {

 //    try {
 //      await orderManagerInstance.purchase();
 //      assert.isTrue(false, "Should have error out. Should have not created a order if status is 2=IN_ARBITRATION!");
 //    } catch (e) {
 //      // console.log(e)
 //      // console.log('yes it errored out as expected since you cannot create a order in status IN_ARBITRATION')
 //      assert.isTrue(true, "should error. Expected outsome so no output!");
 //    }

 //  })


 //  it('should be able to assign arbitrator in the Arbitration contract!', async function() {

 //    await arbitrationManagerInstance.setArbitrator(arbitrationAddress, defaultArbitrator);
 //    // console.log('assigning arbitrator: ' + defaultArbitrator);
 //    let arbitrator = await arbitrationManagerInstance.getArbitrator(arbitrationAddress);
 //    // console.log('returned arbitrator: ' + arbitrator);
 //    assert.equal(defaultArbitrator, arbitrator,"Arbitrator did not get assigned!");

 //  })

 //  it('should seller be able to 2x stake on the arbitration contract', async function() {
 //    await arbitrationManagerInstance.set2xStakeBySeller(arbitrationAddress, { from: defaultSeller });
 //    let status = await arbitrationManagerInstance.getStatus(arbitrationAddress);
 //    // console.log('arbitration status: ' + status);
 //    assert.equal(1,status,"Status is not in 2=SELLER_STAKE_2x as expected!");

 //  })

 // it('should reporter be able to 2x stake on the arbitration contract', async function() {
 //    await arbitrationManagerInstance.set2xStakeByReporter(arbitrationAddress, { from: defaultBuyer });
 //    let status = await arbitrationManagerInstance.getStatus(arbitrationAddress);
 //    // console.log('arbitration status: ' + status);
 //    assert.equal(2,status,"Status is not in 2=REPORTER_STAKE_2x as expected!");

 //  })

 //  it('should arbitrator to set the winner to reporter!', async function() {

 //    console.log('arbitrator: ' + defaultArbitrator);
 //    await arbitrationManagerInstance.setWinner(arbitrationAddress, 1, { from: defaultArbitrator });
 //    let winner = await arbitrationManagerInstance.getWinner(arbitrationAddress);
 //    // console.log('winner is ' + winner)
 //    assert.equal(1, winner,"Winner is not reporter as expected!");

 //  })

 //  it('should asset status be 5=CLOSED after arbitration sides with reporter!', async function() {
 //    let status = await assetManagerInstance.getStatus(assetAddress);
 //    // console.log('status is ' + status);
 //    assert.equal(5,status,"Status is not in 5=CLOSED as expected!");

 //  })


  async function sleep(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }
})