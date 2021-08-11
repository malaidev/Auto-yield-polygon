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

contract('test rebalance', async([alice, bob, admin, dev, minter]) => {

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

        let statbleTokenAddress = await this.xUsdcContract.token();
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xUsdcContract.set_new_APR(this.earnAPRWithPool.address)
        await this.earnAPRWithPool.addXToken(statbleTokenAddress, this.xUsdcContract.address);

        console.log('---ended-before---');
    });

    // it('test supply&withdraw aave', async() => {
    //     // let xusdc = await XUSDC.deployed();
    //     let xusdc = this.xUsdcContract;
    //     const balance = await xusdc.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xusdc.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());

    //     await xusdc.supplyAave(1000);
    //     aave_balance = await xusdc.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());

    //     await xusdc._withdrawAave(100);
    //     aave_balance = await xusdc.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());

    // })

    // it('test supply&withdraw fulcrum', async() => {
    //     // let xusdc = await XUSDC.deployed();
    //     let xusdc = this.xUsdcContract;

    //     const balance = await xusdc.balance();
    //     console.log(balance.toString());

    //     let fulcrum_balance = await xusdc.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());

    //     await xusdc.supplyFulcrum(1000);
    //     fulcrum_balance = await xusdc.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());

    //     await xusdc._withdrawFulcrum(fulcrum_balance);
    //     fulcrum_balance = await xusdc.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    // })

    // it('test supply&withdraw fortube', async() => {
    //     // let xusdc = await XUSDC.deployed();
    //     let xusdc = this.xUsdcContract;

    //     const balance = await xusdc.balance();
    //     console.log(balance.toString());

    //     let fortube_balance = await xusdc.balanceFortube();
    //     console.log('before_fortube_balance', fortube_balance.toString());

    //     await xusdc.supplyFortube(1000);
    //     fortube_balance = await xusdc.balanceFortube();
    //     console.log('fortube_balance', fortube_balance.toString());

    //     await xusdc._withdrawFortube(100);
    //     fortube_balance = await xusdc.balanceFortube();
    //     console.log('current_fortube_balance', fortube_balance.toString());
    // })

    // it('test withdrawAll', async() => {
    //     // let xusdc = await XUSDC.deployed();
    //     let xusdc = this.xUsdcContract;
    //     const balance = await xusdc.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xusdc.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());
    //     let fulcrum_balance = await xusdc.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());
    //     let fortube_balance = await xusdc.balanceFortube();
    //     console.log('before_fortube_balance', fortube_balance.toString());

    //     await xusdc.supplyAave(1000);
    //     aave_balance = await xusdc.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());
    //     await xusdc.supplyFulcrum(1000);
    //     fulcrum_balance = await xusdc.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());
    //     await xusdc.supplyFortube(1000);
    //     fortube_balance = await xusdc.balanceFortube();
    //     console.log('fortube_balance', fortube_balance.toString());

    //     await xusdc._withdrawAll();

    //     aave_balance = await xusdc.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());
    //     fulcrum_balance = await xusdc.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    //     fortube_balance = await xusdc.balanceFortube();
    //     console.log('current_fortube_balance', fortube_balance.toString());

    // })

    it('test rebalance', async() => {
        // let xusdc = await XUSDC.deployed();
        let xusdc = this.xUsdcContract;

        let aave_balance = await xusdc.balanceAave();
        console.log('before_aave_balance', aave_balance.toString());
        let fulcrum_balance = await xusdc.balanceFulcrum();
        console.log('before_fulcrum_balance', fulcrum_balance.toString());
        let fortube_balance = await xusdc.balanceFortube();
        console.log('before_fortube_balance', fortube_balance.toString());

        await xusdc.supplyAave(1000);
        aave_balance = await xusdc.balanceAave();
        console.log('aave_balance', aave_balance.toString());
        await xusdc.supplyFulcrum(1000);
        fulcrum_balance = await xusdc.balanceFulcrum();
        console.log('fulcrum_balance', fulcrum_balance.toString());
        await xusdc.supplyFortube(1000);
        fortube_balance = await xusdc.balanceFortube();
        console.log('fortube_balance', fortube_balance.toString());

        

        await xusdc.rebalance();

        const provider = await xusdc.provider();
        console.log(provider.toString());
        // await xusdc._withdrawAll();

        console.log('current_balance', await xusdc.balance());

        aave_balance = await xusdc.balanceAave();
        console.log('current_aave_balance', aave_balance.toString());
        fulcrum_balance = await xusdc.balanceFulcrum();
        console.log('current_fulcrum_balance', fulcrum_balance.toString());
        fortube_balance = await xusdc.balanceFortube();
        console.log('current_fortube_balance', fortube_balance.toString());
    })
});