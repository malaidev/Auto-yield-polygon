const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XAAVE = artifacts.require('XAAVE')
const ForceSend = artifacts.require('ForceSend');
const aaveABI = require('./abi/aave');

const aaveAddress = '0xD6DF932A45C0f255f85145f286eA0b292B21C90B';
const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);
const aaveOwner = '0x65b1b96bd01926d3d60dd3c8bc452f22819443a9';

contract('test deposit xtoken', async([alice, bob, admin, dev, minter]) => {

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
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xaaveContract.set_new_APR(this.earnAPRWithPool.address)
        
    });

    it('test deposit', async() => {
        // let xaave = await XAAVE.deployed();
        let xaave = this.xaaveContract;
        console.log(xaave.address);

        const aaveAddress = await xaave.token();
        const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);

        console.log(await aaveContract.methods.balanceOf(alice).call());
        await aaveContract.methods.approve(xaave.address, 10000000).send({
            from: alice
        });
        // const allowaneAmount = await aaveContract.methods.allowance(alice, xaave.address);
        // console.log('allowance:', allowaneAmount.toString());

        await xaave.deposit(10000000, {from: alice});
        const balance = await xaave.balance();
        console.log('balance', balance.toString());
    })

    // it('withdraw test', async() => {
    //     let xaave = await XAAVE.deployed();
    //     const aaveAddress = await xaave.token();
    //     const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);

    //     console.log(await aaveContract.methods.balanceOf(alice).call());
    //     // await aaveContract.methods.approve(xaave.address, 10000000).send({
    //     //     from: alice
    //     // });
    //     // const allowaneAmount = await aaveContract.methods.allowance(alice, xaave.address);
    //     // console.log('allowance:', allowaneAmount.toString());

    //     await xaave.withdraw(10000000, {from: alice});
    // })
})