const AssetManager = artifacts.require("./AssetManager.sol");
const OrderManager = artifacts.require("./OrderManager.sol");

const SplytManager = artifacts.require("./SplytManager.sol");
const SatToken = artifacts.require("./SatToken.sol");
const Asset = artifacts.require("./Asset.sol");


contract('OrderManagerTest for fractional general test cases.', function(accounts) {

  const defaultBuyer = accounts[0];
  const defaultBuyer2 = accounts[3];
  const defaultBuyer3 = accounts[4]

  const defaultSeller = accounts[1];
  const defaultMarketPlace = accounts[2];
  const defaultPrice = 1000;
  const defaultExpDate = (new Date().getTime() / 1000) + 60;
  const defaultAssetId = "0x31f2ae92057a7123ef0e490a";
  const defaultAssetFractionalId = "0x31f2ae92057a7123ef0e490b";

  const defaultInventoryCount = 10;

  let satTokenInstance;
  let assetManagerInstance;
  let orderManagerInstance;

  let splytManagerInstance;

  let assetFractionalInstance;
  let assetFractionalAddress;

  //Instantiate the contracts
  init();


  async function create_assetFractional(_assetId = defaultAssetFractionalId, _term = 15, _seller = defaultSeller, _title = "MyTitle",
      _totalCost = defaultPrice, _expirationDate = defaultExpDate, _mpAddress = defaultMarketPlace, _mpAmount = 2, _inventoryCount = 1) {

    await assetManagerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
    assetFractionalAddress = await assetManagerInstance.getAddressById(_assetId);
    assetFractionalInstance = await Asset.at(assetFractionalAddress);

  }



  async function purchase(_orderId = "0x31f2ae92057a7123ef0e490c" , _assetAddress = "0x31f2ae92057a7123ef0e490a", _quantity = 1, _amount = defaultPrice, _buyer = defaultBuyer) {
    console.log('buyer is ' + _buyer)
    await orderManagerInstance.purchase(_orderId, _assetAddress, _quantity, _amount, { from: _buyer });
    // console.log('orderId: ' + orderId);
    // assetInstance = await Asset.at(assetAddress);

  }


  //Instantiate it only once
  async function init() {
    
    console.log('defaultBuyer wallet: ' + defaultBuyer);
    console.log('defaulSeller wallet: ' + defaultSeller);
    console.log('defaultMarketPlace wallet: ' + defaultMarketPlace);

    satTokenInstance = await SatToken.deployed()   
    assetManagerInstance = await AssetManager.deployed()
    splytManagerInstance = await SplytManager.deployed()
    orderManagerInstance = await OrderManager.deployed()

    //give your account some tokens
    // accounts.forEach(async function(acc) {
    //   await satTokenInstance.initUser(acc)
    // })
 
  }

  
  // This function gets ran before every test cases in this file.
  beforeEach('Default instances of contracts for each test', async function() {
    //reinitalize each account balance
    accounts.forEach(async function(acc) {
      await satTokenInstance.initUser(acc)
    })

    // let balance = await satTokenInstance.balanceOf(defaultBuyer)
    // console.log('defaultBuyer balance:' + balance)

    // balance = await satTokenInstance.balanceOf(defaultSeller)
    // console.log('defaultSeller balance:' + balance)

  })


  it('should create new order manager contract successfully!', async function() {    
    let orderManagerAddress = orderManagerInstance.address;
    // console.log('orderManager address: ' + orderManagerAddress)
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(orderManagerAddress, 0x0, "OrderManager has not been deployed!");
  })


  //Tests below are for fractional asset payments
  it('should create fractional asset', async function() {

    await create_assetFractional();

    // console.log('regular asset address: ' + assetAddress);  
    // console.log('fractional asset address: ' + assetFractionalAddress);

    let type = await assetManagerInstance.getType(assetFractionalAddress);
    // console.log('asset type: ' + type);
    // console.log('current inventory count: ' + inventory);
    assert.equal(type, 1, "Asset type is not 1 as expected!");
  })


  it('should get false if there are no contributions', async function() {

    let result = await orderManagerInstance.isFractionalOrderExists(assetFractionalAddress);
    console.log('fractional order exists? ' + result);

    assert.equal(result, false, "Order should be false for fractional payments!");
  })

 
  it('should get status 5=CONTRIBUTIONS_OPEN for fractional asset', async function() {
    await purchase("0x3130", assetFractionalAddress, 0, 500, defaultBuyer);

    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    // console.log('order id: ' + orderId);

    let status = await orderManagerInstance.getStatus(orderId);
    // console.log('status of order: ' + status);

    let totalContributions = await orderManagerInstance.getTotalContributions(orderId);
    // console.log('total contributions: ' + totalContributions);
    
    assert.equal(status, 5, "Order status is not 5=CONTRIBUTIONS_OPEN as expected!");
  })


  it('should get true if there have been any contributions', async function() {

    let result = await orderManagerInstance.isFractionalOrderExists(assetFractionalAddress);
    console.log('fractional order exists? ' + result);

    assert.equal(result, true, "Order should be true for fractional payments!");
  })

  it('should get status 6=CONTRIBUTIONS_FULFILLED for fractional asset', async function() {
    await purchase("0x3130", assetFractionalAddress, 0, 500, defaultBuyer2);

    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    // console.log('order id: ' + orderId);

    let totalContributions = await orderManagerInstance.getTotalContributions(orderId);
    // console.log('total contributions: ' + totalContributions);

    let status = await orderManagerInstance.getStatus(orderId);
    // console.log('status of order: ' + status);

    assert.equal(status, 6, "Order status is not 6=CONTRIBUTIONS_FULFILLED as expected!");
  })

  it('should return asset status 4=SOLD_OUT after all contributions have been made', async function() {
    let status = await assetFractionalInstance.status();
    // console.log('status of asset: ' + status);
    assert.equal(status, 4, "Asset type status not 4=SOLD_OUT as expected!");
  })

  it('should return total number of 1 orders', async function() {
    let length = await orderManagerInstance.getOrdersLength();
    console.log('total orders: ' + length);
    assert.equal(length, 1, "Number of orders is incorrect!");
  })

  it('should return 2 contributors', async function() {
    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    let length = await orderManagerInstance.getContributionsLength(orderId);
    console.log('contributors length: ' + length);
    assert.equal(length, 2, "expected number of contributors is incorrect!");
  })

 
  it('should return defaultBuyer as contributor 1', async function() {
    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    // let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 0);
    let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 0);

    console.log(fields)
    // console.log(fields[1])
    // console.log(fields[2])

    assert.equal(fields[0], defaultBuyer, "expected contributor is incorrect!");
  })

  it('should return defaultBuyer2 as contributor 2', async function() {
    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 1);

    console.log(fields)
    
    assert.equal(fields[0], defaultBuyer2, "expected contributor is incorrect!");
  })

  it('should return total contribution amount as 1000', async function() {
    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    let amount = await orderManagerInstance.getTotalContributions(orderId);

    console.log(amount)
    
    assert.equal(amount, 1000, "expected total contributions is not 1000!");
  })


  it('should return 500 contribution for condtributor 1', async function() {
    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    // let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 0);
    let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 0);
    console.log(fields[0])
    console.log(fields[1])
    console.log(fields[2])
  
    assert.equal(fields[1], 500, "expected contribution of 500 is incorrect!");
  })

  it('should return 500 contribution for condtributor 2', async function() {
    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    // let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 0);
    let fields = await orderManagerInstance.getContributionByOrderIdAndIndex(orderId, 1);
    console.log(fields[0])
    console.log(fields[1])
    console.log(fields[2])
  
    assert.equal(fields[1], 500, "expected contribution of 500 is incorrect!");
  })
})