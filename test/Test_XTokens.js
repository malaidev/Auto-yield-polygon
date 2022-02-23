const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XAAVE = artifacts.require('XAAVE')
const XUSDC = artifacts.require('XUSDC')
const XUSDT = artifacts.require('XUSDT')
const XWBTC = artifacts.require('XWBTC')
const ForceSend = artifacts.require('ForceSend');
const aaveABI = require('./abi/aave');
const usdcABI = require('./abi/usdc');
const usdtABI = require('./abi/usdt');
const wbtcABI = require('./abi/wbtc');

const aaveAddress = '0xD6DF932A45C0f255f85145f286eA0b292B21C90B';
const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);
const aaveOwner = '0x65b1b96bd01926d3d60dd3c8bc452f22819443a9';

const usdcAddress = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174';
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);
const usdcOwner = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';

const usdtAddress = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);
const usdtOwner = '0x2cf7252e74036d1da831d11089d326296e64a728';

const wbtcAddress = '0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6';
const wbtcContract = new web3.eth.Contract(wbtcABI, wbtcAddress);
const wbtcOwner = '0xdC9232E2Df177d7a12FdFf6EcBAb114E2231198D';

contract('test xtoken', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xaaveContract = await XAAVE.new({
            from: alice
        });
        this.xusdcContract = await XUSDC.new({
            from: alice
        });
        this.xusdtContract = await XUSDT.new({
            from: alice
        });
        this.xwbtcContract = await XWBTC.new({
            from: alice
        });
        this.aprWithPoolOracle = await APRWithPoolOracle.new({
            from: alice
        });
        this.earnAPRWithPool = await EarnAPRWithPool.new({
            from: alice
        });

        const forceSend1 = await ForceSend.new();
        await forceSend1.go(aaveOwner, { value: ether('1') });
        const forceSend2 = await ForceSend.new();
        await forceSend2.go(usdcOwner, { value: ether('1') });
        const forceSend3 = await ForceSend.new();
        await forceSend3.go(usdtOwner, { value: ether('1') });
        const forceSend4 = await ForceSend.new();
        await forceSend4.go(wbtcOwner, { value: ether('1') });

        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xaaveContract.set_new_APR(this.earnAPRWithPool.address)
        await this.xusdcContract.set_new_APR(this.earnAPRWithPool.address)
        await this.xusdtContract.set_new_APR(this.earnAPRWithPool.address)
        await this.xwbtcContract.set_new_APR(this.earnAPRWithPool.address)
        
    });

    it('test deposit', async() => {
        let aaveBalance = await aaveContract.methods.balanceOf(aaveOwner).call();
        let usdcBalance = await usdcContract.methods.balanceOf(usdcOwner).call();
        let usdtBalance = await usdtContract.methods.balanceOf(usdtOwner).call();
        let wbtcBalance = await wbtcContract.methods.balanceOf(wbtcOwner).call();        
        // console.log('xaaveContract', aaveBalance.toString());
        // console.log('xusdcContract', usdcBalance.toString());
        // console.log('xusdtContract', usdtBalance.toString());
        // console.log('xwbtcContract', wbtcBalance.toString());

        await aaveContract.methods.transfer(alice, '100000000000000000000').send({ from: aaveOwner});
        console.log('xaaveContract', this.xaaveContract.address);
        await usdcContract.methods.transfer(alice, '100000000').send({ from: usdcOwner});
        console.log('xusdcContract', this.xusdcContract.address);
        await usdtContract.methods.transfer(alice, '100000000').send({ from: usdtOwner});
        console.log('xusdtContract', this.xusdtContract.address);
        await wbtcContract.methods.transfer(alice, '10000000000').send({ from: wbtcOwner});
        console.log('xwbtcContract', this.xwbtcContract.address);
    })
})