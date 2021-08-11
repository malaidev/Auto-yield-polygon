const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XUSDC = artifacts.require('XUSDC')
const ForceSend = artifacts.require('ForceSend');
const usdcABI = require('./abi/usdc');

const usdcAddress = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174';
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);
const usdcOwner = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';

contract('test EarnAPRWithPool', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xUsdcContract = await XUSDC.new({
            from: alice
        });
        this.aprWithPoolOracle = await APRWithPoolOracle.new({
            from: alice
        });
        this.earnAPRWithPool = await EarnAPRWithPool.new({
            from: alice
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(usdcOwner, { value: ether('1') });
        
        await usdcContract.methods.transfer(alice, '10000000000').send({ from: usdcOwner});

        let xusdc = this.xUsdcContract

        await usdcContract.methods.approve(xusdc.address, 10000000).send({
            from: alice
        });

        await xusdc.deposit(10000000, {from: alice});
        console.log('---ended-before---');
    });

    it('recommend test', async() => {
        let aprWithPoolOracle = this.aprWithPoolOracle;
        let earnAPRWithPool = this.earnAPRWithPool;
        let xusdc = this.xUsdcContract;
        let statbleTokenAddress = await xusdc.token();
        await earnAPRWithPool.set_new_APR(aprWithPoolOracle.address)
        await xusdc.set_new_APR(earnAPRWithPool.address)
        await earnAPRWithPool.addXToken(statbleTokenAddress, xusdc.address);

        var atoken = await earnAPRWithPool.aave(statbleTokenAddress);
        const aave_rate = await aprWithPoolOracle.getAaveAPRAdjusted(atoken);
        console.log(aave_rate.toString());

        var ftoken = await earnAPRWithPool.fulcrum(statbleTokenAddress);
        const fulcrum_rate = await aprWithPoolOracle.getFulcrumAPRAdjusted(ftoken, 0)
        console.log(fulcrum_rate.toString());

        var fttoken = await earnAPRWithPool.fortube(statbleTokenAddress);
        const fortube_rate = await aprWithPoolOracle.getFortubeAPRAdjusted(fttoken);
        console.log(fortube_rate.toString());

        // console.log(await xusdc.recommend());
    })
})