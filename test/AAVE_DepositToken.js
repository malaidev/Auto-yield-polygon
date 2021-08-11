const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

// const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
// const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XAAVE = artifacts.require('XAAVE')
const ForceSend = artifacts.require('ForceSend');
const aaveABI = require('./abi/usdc');

const aaveAddress = '0xD6DF932A45C0f255f85145f286eA0b292B21C90B';
const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);
const aaveOwner = '0x8dCF48FB8BC7FDDA5A3106eDe9b7c69Fc2C7E751';

contract('test deposit xtoken', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xaaveContract = await XAAVE.new({
            from: minter
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(aaveOwner, { value: ether('1') });
        
        await aaveContract.methods.transfer(alice, '10000000000').send({ from: aaveOwner});
        
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