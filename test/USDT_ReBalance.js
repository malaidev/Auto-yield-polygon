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

contract('test rebalance', async([alice, bob, admin, dev, minter]) => {

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
        
        await usdtContract.methods.transfer(alice, '10000000').send({ from: usdtOwner});

        let xusdt = this.xusdtContract

        await usdtContract.methods.approve(xusdt.address, 100000).send({
            from: alice
        });

        await xusdt.deposit(100000, {from: alice});

        let statbleTokenAddress = await this.xusdtContract.token();
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xusdtContract.set_new_APR(this.earnAPRWithPool.address)
        await this.earnAPRWithPool.addXToken(statbleTokenAddress, this.xusdtContract.address);

        console.log('---ended-before---');
    });

    // it('test supply&withdraw aave', async() => {
    //     // let xusdt = await XUSDT.deployed();
    //     let xusdt = this.xusdtContract;
    //     const balance = await xusdt.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xusdt.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());

    //     await xusdt.supplyAave(1000);
    //     aave_balance = await xusdt.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());

    //     await xusdt._withdrawAave(100);
    //     aave_balance = await xusdt.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());

    // })

    // it('test supply&withdraw fulcrum', async() => {
    //     // let xusdt = await XUSDT.deployed();
    //     let xusdt = this.xusdtContract;

    //     const balance = await xusdt.balance();
    //     console.log(balance.toString());

    //     let fulcrum_balance = await xusdt.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());

    //     await xusdt.supplyFulcrum(1000);
    //     fulcrum_balance = await xusdt.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());

    //     await xusdt._withdrawFulcrum(fulcrum_balance);
    //     fulcrum_balance = await xusdt.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    // })

    // it('test supply&withdraw fortube', async() => {
    //     // let xusdt = await XUSDT.deployed();
    //     let xusdt = this.xusdtContract;

    //     const balance = await xusdt.balance();
    //     console.log(balance.toString());

    //     let fortube_balance = await xusdt.balanceFortube();
    //     console.log('before_fortube_balance', fortube_balance.toString());

    //     await xusdt.supplyFortube(1000);
    //     fortube_balance = await xusdt.balanceFortube();
    //     console.log('fortube_balance', fortube_balance.toString());

    //     await xusdt._withdrawFortube(fortube_balance);
    //     fortube_balance = await xusdt.balanceFortube();
    //     console.log('current_fortube_balance', fortube_balance.toString());
    // })

    // it('test withdrawAll', async() => {
    //     // let xusdt = await XUSDT.deployed();
    //     let xusdt = this.xusdtContract;
    //     const balance = await xusdt.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xusdt.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());
    //     let fulcrum_balance = await xusdt.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());
    //     let fortube_balance = await xusdt.balanceFortube();
    //     console.log('before_fortube_balance', fortube_balance.toString());

    //     await xusdt.supplyAave(1000);
    //     aave_balance = await xusdt.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());
    //     await xusdt.supplyFulcrum(1000);
    //     fulcrum_balance = await xusdt.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());
    //     await xusdt.supplyFortube(1000);
    //     fortube_balance = await xusdt.balanceFortube();
    //     console.log('fortube_balance', fortube_balance.toString());

    //     await xusdt._withdrawAll();

    //     aave_balance = await xusdt.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());
    //     fulcrum_balance = await xusdt.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    //     fortube_balance = await xusdt.balanceFortube();
    //     console.log('current_fortube_balance', fortube_balance.toString());

    // })

    it('test rebalance', async() => {
        // let xusdt = await XUSDT.deployed();
        let xusdt = this.xusdtContract;

        let aave_balance = await xusdt.balanceAave();
        console.log('before_aave_balance', aave_balance.toString());
        let fulcrum_balance = await xusdt.balanceFulcrum();
        console.log('before_fulcrum_balance', fulcrum_balance.toString());
        let fortube_balance = await xusdt.balanceFortube();
        console.log('before_fortube_balance', fortube_balance.toString());

        await xusdt.supplyAave(1000);
        aave_balance = await xusdt.balanceAave();
        console.log('aave_balance', aave_balance.toString());
        await xusdt.supplyFulcrum(1000);
        fulcrum_balance = await xusdt.balanceFulcrum();
        console.log('fulcrum_balance', fulcrum_balance.toString());
        await xusdt.supplyFortube(1000);
        fortube_balance = await xusdt.balanceFortube();
        console.log('fortube_balance', fortube_balance.toString());

        

        await xusdt.rebalance();
        // await xusdt._withdrawAll();

        console.log('current_balance', await xusdt.balance());

        aave_balance = await xusdt.balanceAave();
        console.log('current_aave_balance', aave_balance.toString());
        fulcrum_balance = await xusdt.balanceFulcrum();
        console.log('current_fulcrum_balance', fulcrum_balance.toString());
        fortube_balance = await xusdt.balanceFortube();
        console.log('current_fortube_balance', fortube_balance.toString());
    })
});