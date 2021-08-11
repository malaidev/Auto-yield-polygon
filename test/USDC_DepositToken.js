const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

// const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
// const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XUSDC = artifacts.require('XUSDC')
const ForceSend = artifacts.require('ForceSend');
const usdcABI = require('./abi/usdc');

const usdcAddress = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174';
const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);
const usdcOwner = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';

contract('test deposit xtoken', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xUsdcContract = await XUSDC.new({
            from: minter
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(usdcOwner, { value: ether('1') });
        
        await usdcContract.methods.transfer(alice, '10000000000').send({ from: usdcOwner});
        
    });

    it('test deposit', async() => {
        // let xusdc = await XUSDC.deployed();
        let xusdc = this.xUsdcContract;
        console.log(xusdc.address);

        const usdcAddress = await xusdc.token();
        const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

        console.log(await usdcContract.methods.balanceOf(alice).call());
        await usdcContract.methods.approve(xusdc.address, 10000000).send({
            from: alice
        });
        // const allowaneAmount = await usdcContract.methods.allowance(alice, xusdc.address);
        // console.log('allowance:', allowaneAmount.toString());

        await xusdc.deposit(10000000, {from: alice});
        const balance = await xusdc.balance();
        console.log('balance', balance.toString());
    })

    // it('withdraw test', async() => {
    //     let xusdc = await XUSDC.deployed();
    //     const usdcAddress = await xusdc.token();
    //     const usdcContract = new web3.eth.Contract(usdcABI, usdcAddress);

    //     console.log(await usdcContract.methods.balanceOf(alice).call());
    //     // await usdcContract.methods.approve(xusdc.address, 10000000).send({
    //     //     from: alice
    //     // });
    //     // const allowaneAmount = await usdcContract.methods.allowance(alice, xusdc.address);
    //     // console.log('allowance:', allowaneAmount.toString());

    //     await xusdc.withdraw(10000000, {from: alice});
    // })
})