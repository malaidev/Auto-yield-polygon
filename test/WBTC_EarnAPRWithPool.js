const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XWBTC = artifacts.require('XWBTC')
const ForceSend = artifacts.require('ForceSend');
const wbtcABI = require('./abi/wbtc');

const wbtcAddress = '0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6';
const wbtcContract = new web3.eth.Contract(wbtcABI, wbtcAddress);
const wbtcOwner = '0xdC9232E2Df177d7a12FdFf6EcBAb114E2231198D';

contract('test EarnAPRWithPool', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xwbtcContract = await XWBTC.new({
            from: alice
        });
        this.aprWithPoolOracle = await APRWithPoolOracle.new({
            from: alice
        });
        this.earnAPRWithPool = await EarnAPRWithPool.new({
            from: alice
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(wbtcOwner, { value: ether('1') });
        
        await wbtcContract.methods.transfer(alice, '10000000000').send({ from: wbtcOwner});

        let xwbtc = this.xwbtcContract

        await wbtcContract.methods.approve(xwbtc.address, 10000000).send({
            from: alice
        });

        await xwbtc.deposit(10000000, {from: alice});
        console.log('---ended-before---');
    });

    it('recommend test', async() => {
        let aprWithPoolOracle = this.aprWithPoolOracle;
        let earnAPRWithPool = this.earnAPRWithPool;
        let xwbtc = this.xwbtcContract;
        let statbleTokenAddress = await xwbtc.token();
        await earnAPRWithPool.set_new_APR(aprWithPoolOracle.address)
        await xwbtc.set_new_APR(earnAPRWithPool.address)
        await earnAPRWithPool.addXToken(statbleTokenAddress, xwbtc.address);

        var atoken = await earnAPRWithPool.aave(statbleTokenAddress);
        const aave_rate = await aprWithPoolOracle.getAaveAPRAdjusted(atoken);
        console.log(aave_rate.toString());

        var ftoken = await earnAPRWithPool.fulcrum(statbleTokenAddress);
        const fulcrum_rate = await aprWithPoolOracle.getFulcrumAPRAdjusted(ftoken, 0)
        console.log(fulcrum_rate.toString());

        var fttoken = await earnAPRWithPool.fortube(statbleTokenAddress);
        const fortube_rate = await aprWithPoolOracle.getFortubeAPRAdjusted(fttoken);
        console.log(fortube_rate.toString());

        // console.log(await xwbtc.recommend());
    })
})