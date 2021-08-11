const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

// const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
// const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XWBTC = artifacts.require('XWBTC')
const ForceSend = artifacts.require('ForceSend');
const wbtcABI = require('./abi/wbtc');

const wbtcAddress = '0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6';
const wbtcContract = new web3.eth.Contract(wbtcABI, wbtcAddress);
const wbtcOwner = '0xdC9232E2Df177d7a12FdFf6EcBAb114E2231198D';

contract('test deposit xtoken', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xwbtcContract = await XWBTC.new({
            from: minter
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(wbtcOwner, { value: ether('1') });
        
        await wbtcContract.methods.transfer(alice, '10000000000').send({ from: wbtcOwner});
        
    });

    it('test deposit', async() => {
        // let xwbtc = await XWBTC.deployed();
        let xwbtc = this.xwbtcContract;
        console.log(xwbtc.address);

        const wbtcAddress = await xwbtc.token();
        const wbtcContract = new web3.eth.Contract(wbtcABI, wbtcAddress);

        console.log(await wbtcContract.methods.balanceOf(alice).call());
        await wbtcContract.methods.approve(xwbtc.address, 10000000).send({
            from: alice
        });
        // const allowaneAmount = await wbtcContract.methods.allowance(alice, xwbtc.address);
        // console.log('allowance:', allowaneAmount.toString());

        await xwbtc.deposit(10000000, {from: alice});
        const balance = await xwbtc.balance();
        console.log('balance', balance.toString());
    })

    // it('withdraw test', async() => {
    //     let xwbtc = await XWBTC.deployed();
    //     const wbtcAddress = await xwbtc.token();
    //     const wbtcContract = new web3.eth.Contract(wbtcABI, wbtcAddress);

    //     console.log(await wbtcContract.methods.balanceOf(alice).call());
    //     // await wbtcContract.methods.approve(xwbtc.address, 10000000).send({
    //     //     from: alice
    //     // });
    //     // const allowaneAmount = await wbtcContract.methods.allowance(alice, xwbtc.address);
    //     // console.log('allowance:', allowaneAmount.toString());

    //     await xwbtc.withdraw(10000000, {from: alice});
    // })
})