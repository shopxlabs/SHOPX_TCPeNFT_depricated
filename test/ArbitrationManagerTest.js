const AssetManager = artifacts.require("./AssetManager.sol");
const OrderManager = artifacts.require("./OrderManager.sol");
const ArbitrationManager = artifacts.require("./ArbitrationManager.sol");

const SplytManager = artifacts.require("./SplytManager.sol");
const SatToken = artifacts.require("./SatToken.sol");
const Asset = artifacts.require("./Asset.sol");
const Arbitration = artifacts.require("./Arbitration.sol");


contract('ArbitrationManagerTest general test cases.', function(accounts) {

  const defaultBuyer = accounts[0];
  const defaultSeller = accounts[1];
  const defaultMarketPlace = accounts[2];
  const defaultArbitrator = accounts[3];
  
  const defaultPrice = 1000;
  const defaultExpDate = (new Date().getTime() / 1000) + 60;
  const defaultAssetId = "0x31f2ae92057a7123ef0e490a";
  const defaultArbitrationId = "0x31f2ae92057a7123ef0e490a";

  const defaultInventoryCount = 2;


  let satTokenInstance;
  let assetManagerInstance;
  let orderManagerInstance;

  let splytManagerInstance;
  let assetInstance;
  let assetAddress;

  let arbitrationInstance;
  let arbitrationAddress;

  //Instantiate the contracts
  init();

  async function create_asset(_assetId = defaultAssetId, _term = 0, _seller = defaultSeller, _title = "MyTitle",
      _totalCost = defaultPrice, _expirationDate = defaultExpDate, _mpAddress = defaultMarketPlace, _mpAmount = 2, _inventoryCount = defaultInventoryCount) {

    await assetManagerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
    assetAddress = await assetManagerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);

  }

  async function create_arbitration(_assetAddress = assetAddress, _arbitrationId = "0x31f2ae92057a7123ef0e490a", _reason = 1) {

    await arbitrationManagerInstance.createArbitration(_arbitrationId, assetAddress, _reason, { from: defaultBuyer });
    arbitrationAddress = await arbitrationManagerInstance.getAddressById(_arbitrationId);
    arbitrationInstance = Arbitration.at(arbitrationAddress);

  }

  async function purchase(_orderId = "0x3031", _assetAddress = assetAddress, _quantity = 1, _amount = defaultPrice) {

    await orderManagerInstance.purchase(_orderId, _assetAddress, _quantity, _amount, { from: defaultBuyer });
    // assetInstance = await Asset.at(assetAddress);

  }

  //Instantiate it only once
  async function init() {
    
    console.log('defaultBuyer wallet: ' + defaultBuyer);
    console.log('defaulSeller wallet: ' + defaultSeller);
    console.log('defaultMarketPlace wallet: ' + defaultMarketPlace);

    satTokenInstance = await SatToken.deployed()   
    arbitrationManagerInstance = await ArbitrationManager.deployed()
    assetManagerInstance = await AssetManager.deployed()
    splytManagerInstance = await SplytManager.deployed()
    ordertManagerInstance = await OrderManager.deployed()    
 
  }

  
  // This function gets ran before every test cases in this file.
  beforeEach('Default instances of contracts for each test', async function() {
    //reinitalize each account balance
    accounts.forEach(async function(acc) {
      await satTokenInstance.initUser(acc, 205000000)
    })

    // let balance = await satTokenInstance.balanceOf(defaultBuyer)
    // console.log('defaultBuyer balance:' + balance)

    // balance = await satTokenInstance.balanceOf(defaultSeller)
    // console.log('defaultSeller balance:' + balance)

  })


  it('should be new arbitration manager contract successfully!', async function() {    
    let arbitrationManagerAddress = arbitrationManagerInstance.address;
    // console.log('orderManager address: ' + orderManagerAddress)
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(arbitrationManagerAddress, 0x0, "Arbitration manager has not been deployed!");
  })

  it('should be 1 arbitration contract successfully!', async function() {
    
    await create_asset();
    await create_arbitration();

    let length = await arbitrationManagerInstance.getArbitrationsLength();
    // console.log('number of arbitrations: ' + length);
    assert.equal(length, 1, "Number of arbitrations is not 1!");
  })



  it('should return arbitration info by 0=index', async function() {
    
    let fields = await arbitrationManagerInstance.getArbitrationInfoByIndex(0);
    console.log('arbitration infos:')
    console.log(fields);
    // assert.equal(status, 2, "Status is not in IN_ARBITRATION!");
  })


  it('should be asset status 2=IN_ARBITRATION after reporter creates an arbitration!', async function() {
    
    let status = await assetInstance.status();

    // console.log('asset status after being reported:: ' + status);
    assert.equal(status, 2, "Status is not in IN_ARBITRATION!");
  })


  it('should arbitration status be 0=REPORTED after arbitration creation', async function() {
    let status = await arbitrationManagerInstance.getStatus('0x31f2ae92057a7123ef0e490a');
    console.log('status is ' + status);
    assert.equal(0,status,"Status is not in 0=REPORTED as expected!");

  })


  it('should not be able to purchase order a asset in status 2=IN_ARBITRATION!', async function() {

    try {
      await orderManagerInstance.purchase();
      assert.isTrue(false, "Should have error out. Should have not created a order if status is 2=IN_ARBITRATION!");
    } catch (e) {
      // console.log(e)
      // console.log('yes it errored out as expected since you cannot create a order in status IN_ARBITRATION')
      assert.isTrue(true, "should error. Expected outsome so no output!");
    }

  })


  it('should seller be able to 2x stake on the arbitration contract', async function() {
    await arbitrationManagerInstance.set2xStakeBySeller("0x31f2ae92057a7123ef0e490a", { from: defaultSeller });
    let status = await arbitrationManagerInstance.getStatus("0x31f2ae92057a7123ef0e490a");
    console.log('arbitration status: ' + status);
    assert.equal(1,status,"Status is not in 2=SELLER_STAKE_2x as expected!");

  })


 it('should reporter be able to 2x stake on the arbitration contract', async function() {
    await arbitrationManagerInstance.set2xStakeByReporter("0x31f2ae92057a7123ef0e490a", { from: defaultBuyer });
    let status = await arbitrationManagerInstance.getStatus("0x31f2ae92057a7123ef0e490a");
    // console.log('arbitration status: ' + status);
    assert.equal(2,status,"Status is not in 2=REPORTER_STAKE_2X as expected!");

  })

  it('should be able to assign arbitrator in the Arbitration contract!', async function() {

    await arbitrationManagerInstance.setArbitrator("0x31f2ae92057a7123ef0e490a", defaultArbitrator);
    // console.log('assigning arbitrator: ' + defaultArbitrator);
    let arbitrator = await arbitrationManagerInstance.getArbitrator("0x31f2ae92057a7123ef0e490a");
    // console.log('returned arbitrator: ' + arbitrator);
    assert.equal(defaultArbitrator, arbitrator,"Arbitrator did not get assigned!");

  }) 

  it('should arbitrator to set the winner to reporter!', async function() {
    let status = await assetManagerInstance.getStatus(assetAddress);
    console.log('status: ' + status);
    await arbitrationManagerInstance.setWinner("0x31f2ae92057a7123ef0e490a", 1, { from: defaultArbitrator });
    let winner = await arbitrationManagerInstance.getWinner("0x31f2ae92057a7123ef0e490a");
    // console.log('winner is ' + winner)
    assert.equal(1, winner,"Winner is not reporter as expected!");

  })


  it('should arbitration status be 4=RESOLVED after decision!', async function() {
    let status = await arbitrationManagerInstance.getStatus('0x31f2ae92057a7123ef0e490a');
    console.log('status: ' + status);
    // console.log('winner is ' + winner)
    assert.equal(4, status,"Status for RESOLVED incorrect");

  })


  it('should asset status be 5=CLOSED after arbitration sides with reporter!', async function() {
    let status = await assetManagerInstance.getStatus(assetAddress);
    console.log('status is ' + status);
    assert.equal(5,status,"Status is not in 5=CLOSED as expected!");

  })


  async function sleep(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }
})