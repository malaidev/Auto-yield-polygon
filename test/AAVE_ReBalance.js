const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XAAVE = artifacts.require('XAAVE')
const ForceSend = artifacts.require('ForceSend');
const aaveABI = require('./abi/aave');

const aaveAddress = '0xD6DF932A45C0f255f85145f286eA0b292B21C90B';
const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);
const aaveOwner = '0x8dCF48FB8BC7FDDA5A3106eDe9b7c69Fc2C7E751';

contract('test rebalance', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xaaveContract = await XAAVE.new({
            from: alice
        });
        this.aprWithPoolOracle = await APRWithPoolOracle.new({
            from: alice
        });
        this.earnAPRWithPool = await EarnAPRWithPool.new({
            from: alice
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(aaveOwner, { value: ether('1') });
        
        await aaveContract.methods.transfer(alice, '10000000000').send({ from: aaveOwner});

        let xaave = this.xaaveContract

        let statbleTokenAddress = await this.xaaveContract.token();
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xaaveContract.set_new_APR(this.earnAPRWithPool.address)
        await this.earnAPRWithPool.addXToken(statbleTokenAddress, this.xaaveContract.address);

        await aaveContract.methods.approve(xaave.address, 10000000).send({
            from: alice
        });

        await xaave.deposit(10000000, {from: alice});

        console.log('---ended-before---');
    });

    // it('test supply&withdraw aave', async() => {
    //     // let xaave = await XAAVE.deployed();
    //     let xaave = this.xaaveContract;
    //     const balance = await xaave.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xaave.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());

    //     await xaave.supplyAave(1000);
    //     aave_balance = await xaave.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());

    //     await xaave._withdrawAave(100);
    //     aave_balance = await xaave.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());

    // })

    // it('test supply&withdraw fulcrum', async() => {
    //     // let xaave = await XAAVE.deployed();
    //     let xaave = this.xaaveContract;

    //     const balance = await xaave.balance();
    //     console.log(balance.toString());

    //     let fulcrum_balance = await xaave.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());

    //     await xaave.supplyFulcrum(1000);
    //     fulcrum_balance = await xaave.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());

    //     await xaave._withdrawFulcrum(fulcrum_balance);
    //     fulcrum_balance = await xaave.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());
    // })

    // it('test withdrawAll', async() => {
    //     // let xaave = await XAAVE.deployed();
    //     let xaave = this.xaaveContract;
    //     const balance = await xaave.balance();
    //     console.log(balance.toString());

    //     let aave_balance = await xaave.balanceAave();
    //     console.log('before_aave_balance', aave_balance.toString());
    //     let fulcrum_balance = await xaave.balanceFulcrum();
    //     console.log('before_fulcrum_balance', fulcrum_balance.toString());

    //     await xaave.supplyAave(1000);
    //     aave_balance = await xaave.balanceAave();
    //     console.log('aave_balance', aave_balance.toString());
    //     await xaave.supplyFulcrum(1000);
    //     fulcrum_balance = await xaave.balanceFulcrum();
    //     console.log('fulcrum_balance', fulcrum_balance.toString());

    //     await xaave._withdrawAll();

    //     aave_balance = await xaave.balanceAave();
    //     console.log('current aave_balance', aave_balance.toString());
    //     fulcrum_balance = await xaave.balanceFulcrum();
    //     console.log('current_fulcrum_balance', fulcrum_balance.toString());

    // })

    it('test rebalance', async() => {
        // let xaave = await XAAVE.deployed();
        let xaave = this.xaaveContract;

        let aave_balance = await xaave.balanceAave();
        console.log('before_aave_balance', aave_balance.toString());
        let fulcrum_balance = await xaave.balanceFulcrum();
        console.log('before_fulcrum_balance', fulcrum_balance.toString());

        await xaave.supplyAave(1000);
        aave_balance = await xaave.balanceAave();
        console.log('aave_balance', aave_balance.toString());
        await xaave.supplyFulcrum(1000);
        fulcrum_balance = await xaave.balanceFulcrum();
        console.log('fulcrum_balance', fulcrum_balance.toString());        

        await xaave.rebalance();

        const provider = await xaave.provider();
        console.log(provider.toString());
        // await xaave._withdrawAll();

        console.log('current_balance', await xaave.balance());

        aave_balance = await xaave.balanceAave();
        console.log('current_aave_balance', aave_balance.toString());
        fulcrum_balance = await xaave.balanceFulcrum();
        console.log('current_fulcrum_balance', fulcrum_balance.toString());
    })
});