const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XUSDT = artifacts.require('XUSDT')
const ForceSend = artifacts.require('ForceSend');
const usdtABI = require('./abi/usdt');

const usdtAddress = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);
const usdtOwner = '0x2cf7252e74036d1da831d11089d326296e64a728';

contract('test EarnAPRWithPool', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xusdtContract = await XUSDT.new({
            from: alice
        });
        this.aprWithPoolOracle = await APRWithPoolOracle.new({
            from: alice
        });
        this.earnAPRWithPool = await EarnAPRWithPool.new({
            from: alice
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(usdtOwner, { value: ether('1') });
        
        await usdtContract.methods.transfer(alice, '100000').send({ from: usdtOwner});

        let xusdt = this.xusdtContract

        await usdtContract.methods.approve(xusdt.address, 100000).send({
            from: alice
        });

        await xusdt.deposit(100000, {from: alice});
        console.log('---ended-before---');
    });

    it('recommend test', async() => {
        let aprWithPoolOracle = this.aprWithPoolOracle;
        let earnAPRWithPool = this.earnAPRWithPool;
        let xusdt = this.xusdtContract;
        let statbleTokenAddress = await xusdt.token();
        await earnAPRWithPool.set_new_APR(aprWithPoolOracle.address)
        await xusdt.set_new_APR(earnAPRWithPool.address)
        await earnAPRWithPool.addXToken(statbleTokenAddress, xusdt.address);

        var atoken = await earnAPRWithPool.aave(statbleTokenAddress);
        const aave_rate = await aprWithPoolOracle.getAaveAPRAdjusted(atoken);
        console.log(aave_rate.toString());

        var ftoken = await earnAPRWithPool.fulcrum(statbleTokenAddress);
        const fulcrum_rate = await aprWithPoolOracle.getFulcrumAPRAdjusted(ftoken, 0)
        console.log(fulcrum_rate.toString());

        var fttoken = await earnAPRWithPool.fortube(statbleTokenAddress);
        const fortube_rate = await aprWithPoolOracle.getFortubeAPRAdjusted(fttoken);
        console.log(fortube_rate.toString());

        // console.log(await xusdt.recommend());
    })
})