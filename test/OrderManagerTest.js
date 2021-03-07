const AssetManager = artifacts.require("./AssetManager.sol");
const OrderManager = artifacts.require("./OrderManager.sol");

const SplytManager = artifacts.require("./SplytManager.sol");
const ShopxToken = artifacts.require("./ShopxToken.sol");
const Asset = artifacts.require("./Asset.sol");


contract('OrderManagerTest general test cases.', function(accounts) {

  const defaultBuyer = accounts[0];
  const defaultSeller = accounts[1];
  const defaultMarketPlace = accounts[2];
  const defaultPrice = 1000;
  const defaultExpDate = (new Date().getTime() / 1000) + 60;
  const defaultAssetId = "0x31f2ae92057a7123ef0e490a";
  const defaultAssetFractionalId = "0x31f2ae92057a7123ef0e490b";

  const defaultInventoryCount = 10;

  let shopxTokenInstance;
  let assetManagerInstance;
  let orderManagerInstance;

  let splytManagerInstance;
  let assetInstance;
  let assetAddress;

  let assetFractionalInstance;
  let assetFractionalAddress;

  //Instantiate the contracts
  init();

  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 0, _seller = defaultSeller, _title = "MyTitle",
      _totalCost = defaultPrice, _expirationDate = defaultExpDate, _mpAddress = defaultMarketPlace, _mpAmount = 2, _inventoryCount = defaultInventoryCount) {

    await assetManagerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
    assetAddress = await assetManagerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);

  }

  async function create_assetFractional(_assetId = defaultAssetFractionalId, _term = 15, _seller = defaultSeller, _title = "MyTitle",
      _totalCost = defaultPrice, _expirationDate = defaultExpDate, _mpAddress = defaultMarketPlace, _mpAmount = 2, _inventoryCount = 1) {

    await assetManagerInstance.createAsset(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount);
    assetFractionalAddress = await assetManagerInstance.getAddressById(_assetId);
    assetFractionalInstance = await Asset.at(assetFractionalAddress);

  }



  async function purchase(_orderId = "0x31f2ae92057a7123ef0e490c" , _assetAddress = "0x31f2ae92057a7123ef0e490a", _quantity = 1, _amount = defaultPrice) {

    await orderManagerInstance.purchase(_orderId, _assetAddress, _quantity, _amount, { from: defaultBuyer });
    // console.log('orderId: ' + orderId);
    // assetInstance = await Asset.at(assetAddress);

  }


  //Instantiate it only once
  async function init() {
    
    console.log('defaultBuyer wallet: ' + defaultBuyer);
    console.log('defaulSeller wallet: ' + defaultSeller);
    console.log('defaultMarketPlace wallet: ' + defaultMarketPlace);

    shopxTokenInstance = await shopxTokenInstance.deployed()   
    assetManagerInstance = await AssetManager.deployed()
    splytManagerInstance = await SplytManager.deployed()
    orderManagerInstance = await OrderManager.deployed()

    //give your account some tokens
    // accounts.forEach(async function(acc) {
    //   await shopxTokenInstance.initUser(acc, 205000000)
    // })
 
  }

  
  // This function gets ran before every test cases in this file.
  beforeEach('Default instances of contracts for each test', async function() {
    //reinitalize each account balance
    accounts.forEach(async function(acc) {
      await shopxTokenInstance.initUser(acc, 205000000)
    })

    // let balance = await shopxTokenInstance.balanceOf(defaultBuyer)
    // console.log('defaultBuyer balance:' + balance)

    // balance = await shopxTokenInstance.balanceOf(defaultSeller)
    // console.log('defaultSeller balance:' + balance)

  })


  it('should create new order manager contract successfully!', async function() {    
    let orderManagerAddress = orderManagerInstance.address;
    // console.log('orderManager address: ' + orderManagerAddress)
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(orderManagerAddress, 0x0, "OrderManager has not been deployed!");
  })

  it('should deploy new order contract successfully!', async function() {
    await create_asset();
    await purchase("0x31", assetAddress, 2, (1000 * 2));
    let length = await orderManagerInstance.getOrdersLength();
    // console.log('number of orders: ' + length);
    assert.equal(length, 1, "Number of orders is not 1!");
  })

  it('should retrireve order info by orderId', async function() {

    let infos = await orderManagerInstance.getOrderInfoByOrderId("0x31");
    // console.log(infos)
    // console.log('current inventory count: ' + currentInventory);
    assert.equal(infos[1], "0x310000000000000000000000", "orderId is not matching as expected");

  })

  it('should retrireve order info by index', async function() {

    let infos = await orderManagerInstance.getOrderInfoByIndex(0);
    console.log(infos)
    // console.log('current inventory count: ' + currentInventory);
    assert.equal(infos[1], "0x310000000000000000000000", "orderId is not matching as expected");

  })

  it('should current inventory at 8', async function() {

    let currentInventory = await assetInstance.inventoryCount();
    // console.log('current inventory count: ' + currentInventory);
    assert.equal(8, currentInventory, "Initial inventory count is not expected!");

  })


  it('should defaultBuyer balance be less than 1000 off original balance', async function() {
    await create_asset();

    let initBalance = await shopxTokenInstance.balanceOf(defaultBuyer);
    // console.log('before purchase balance:' + initBalance);

    await purchase("0x32", assetAddress, 1, 1000);

    let updatedBalance = await shopxTokenInstance.balanceOf(defaultBuyer);
    // console.log('after purchase balance:' + updatedBalance);

    assert.equal((initBalance - defaultPrice), updatedBalance, "Balance is not -1000 as expected!");
  })

  it('should deploy new purchase order contract making total of 3 successfully!', async function() {
    await purchase("0x33", assetAddress, 1, defaultPrice);
    let length = await orderManagerInstance.getOrdersLength();
    console.log('number of orders: ' + length);
    assert.equal(length, 3, "Number of orders is not 2!");
  })


  it('should buyer be able to request a refund!', async function() {
    let status = await orderManagerInstance.getStatus(1);
    // console.log('current status: ' + status);
    await orderManagerInstance.requestRefund("0x31", { from: defaultBuyer });
    status = await orderManagerInstance.getStatus("0x31");
    // console.log('status after requesting a refund: ' + status);
    assert.equal(status, 3, "status not in 2=REQUESTED_REFUND!");
  })

  it('should seller be able to approve refund!', async function() {
    let status = await orderManagerInstance.getStatus("0x31");
    // console.log('current status: ' + status);
    await orderManagerInstance.approveRefund("0x31", { from: defaultSeller });
    status = await orderManagerInstance.getStatus("0x31");
    // console.log('status after requesting a refund: ' + status);
    assert.equal(status, 4, "status not in 4=REFUND_APPROVED!");
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

 
  it('should get status 5=CONTRIBUTIONS_OPEN for fractional asset', async function() {
    await purchase("0x3130", assetFractionalAddress, 0, 500);

    let orderId = await orderManagerInstance.getFractionalOrderIdByAsset(assetFractionalAddress);
    // console.log('order id: ' + orderId);

    let status = await orderManagerInstance.getStatus(orderId);
    // console.log('status of order: ' + status);

    let totalContributions = await orderManagerInstance.getTotalContributions(orderId);
    // console.log('total contributions: ' + totalContributions);
    
    assert.equal(status, 5, "Order status is not 5=CONTRIBUTIONS_OPEN as expected!");
  })

  it('should get status 6=CONTRIBUTIONS_FULFILLED for fractional asset', async function() {
    await purchase("0x3130", assetFractionalAddress, 0, 500);

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


})