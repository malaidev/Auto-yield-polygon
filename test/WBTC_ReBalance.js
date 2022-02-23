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

contract('test rebalance', async([alice, bob, admin, dev, minter]) => {

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

        let statbleTokenAddress = await this.xwbtcContract.token();
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xwbtcContract.set_new_APR(this.earnAPRWithPool.address)
        await this.earnAPRWithPool.addXToken(statbleTokenAddress, this.xwbtcContract.address);

        await wbtcContract.methods.approve(xwbtc.address, 10000000).send({
            from: alice
        });

        await xwbtc.deposit(10000000, {from: alice});

        console.log('---ended-before---');
    });

    // it('test supply&withdraw aave', async() => {
    //     // let xwbtc = await XWBTC.deployed();
    //     let xwbtc = this.xwbtcContract;
    //     const balance = await xwbtc.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xwbtc.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());

    //     await xwbtc.supplyAave(1000);
    //     aave_balance = await xwbtc.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());

    //     await xwbtc._withdrawAave(100);
    //     aave_balance = await xwbtc.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());

    // })

    // it('test supply&withdraw fulcrum', async() => {
    //     // let xwbtc = await XWBTC.deployed();
    //     let xwbtc = this.xwbtcContract;

    //     const balance = await xwbtc.balance();
    //     console.log(balance.toString());

    //     let fulcrum_balance = await xwbtc.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());

    //     await xwbtc.supplyFulcrum(1000);
    //     fulcrum_balance = await xwbtc.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());

    //     await xwbtc._withdrawFulcrum(fulcrum_balance);
    //     fulcrum_balance = await xwbtc.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    // })

    // it('test supply&withdraw fortube', async() => {
    //     // let xwbtc = await XWBTC.deployed();
    //     let xwbtc = this.xwbtcContract;

    //     const balance = await xwbtc.balance();
    //     console.log(balance.toString());

    //     let fortube_balance = await xwbtc.balanceFortube();
    //     console.log('before_fortube_balance', fortube_balance.toString());

    //     await xwbtc.supplyFortube(1000);
    //     fortube_balance = await xwbtc.balanceFortube();
    //     console.log('fortube_balance', fortube_balance.toString());

    //     await xwbtc._withdrawFortube(100);
    //     fortube_balance = await xwbtc.balanceFortube();
    //     console.log('current_fortube_balance', fortube_balance.toString());
    // })

    // it('test withdrawAll', async() => {
    //     // let xwbtc = await XWBTC.deployed();
    //     let xwbtc = this.xwbtcContract;
    //     const balance = await xwbtc.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xwbtc.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());
    //     let fulcrum_balance = await xwbtc.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());
    //     let fortube_balance = await xwbtc.balanceFortube();
    //     console.log('before_fortube_balance', fortube_balance.toString());

    //     await xwbtc.supplyAave(1000);
    //     aave_balance = await xwbtc.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());
    //     await xwbtc.supplyFulcrum(1000);
    //     fulcrum_balance = await xwbtc.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());
    //     await xwbtc.supplyFortube(1000);
    //     fortube_balance = await xwbtc.balanceFortube();
    //     console.log('fortube_balance', fortube_balance.toString());

    //     await xwbtc._withdrawAll();

    //     aave_balance = await xwbtc.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());
    //     fulcrum_balance = await xwbtc.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    //     fortube_balance = await xwbtc.balanceFortube();
    //     console.log('current_fortube_balance', fortube_balance.toString());

    // })

    it('test rebalance', async() => {
        // let xwbtc = await XWBTC.deployed();
        let xwbtc = this.xwbtcContract;

        let aave_balance = await xwbtc.balanceAave();
        console.log('before_aave_balance', aave_balance.toString());
        let fulcrum_balance = await xwbtc.balanceFulcrum();
        console.log('before_fulcrum_balance', fulcrum_balance.toString());
        let fortube_balance = await xwbtc.balanceFortube();
        console.log('before_fortube_balance', fortube_balance.toString());

        await xwbtc.supplyAave(1000);
        aave_balance = await xwbtc.balanceAave();
        console.log('aave_balance', aave_balance.toString());
        await xwbtc.supplyFulcrum(1000);
        fulcrum_balance = await xwbtc.balanceFulcrum();
        console.log('fulcrum_balance', fulcrum_balance.toString());
        await xwbtc.supplyFortube(1000);
        fortube_balance = await xwbtc.balanceFortube();
        console.log('fortube_balance', fortube_balance.toString());

        

        await xwbtc.rebalance();

        const provider = await xwbtc.provider();
        console.log(provider.toString());
        // await xwbtc._withdrawAll();

        console.log('current_balance', await xwbtc.balance());

        aave_balance = await xwbtc.balanceAave();
        console.log('current_aave_balance', aave_balance.toString());
        fulcrum_balance = await xwbtc.balanceFulcrum();
        console.log('current_fulcrum_balance', fulcrum_balance.toString());
        fortube_balance = await xwbtc.balanceFortube();
        console.log('current_fortube_balance', fortube_balance.toString());
    })
});