const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

// const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
// const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const XUSDT = artifacts.require('XUSDT')
const ForceSend = artifacts.require('ForceSend');
const usdtABI = require('./abi/usdt');

const usdtAddress = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';
const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);
const usdtOwner = '0x2cf7252e74036d1da831d11089d326296e64a728';

contract('test deposit xtoken', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.xusdtContract = await XUSDT.new({
            from: minter
        });

        const forceSend = await ForceSend.new();
        await forceSend.go(usdtOwner, { value: ether('1') });
        
        await usdtContract.methods.transfer(alice, '100000').send({ from: usdtOwner});
        
    });

    it('test deposit', async() => {
        // let xusdt = await XUSDT.deployed();
        let xusdt = this.xusdtContract;
        console.log(xusdt.address);

        const usdtAddress = await xusdt.token();
        const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

        console.log(await usdtContract.methods.balanceOf(alice).call());
        await usdtContract.methods.approve(xusdt.address, 100000).send({
            from: alice
        });
        // const allowaneAmount = await usdtContract.methods.allowance(alice, xusdt.address);
        // console.log('allowance:', allowaneAmount.toString());

        await xusdt.deposit(100000, {from: alice});
        const balance = await xusdt.balance();
        console.log('balance', balance.toString());
    })

    // it('withdraw test', async() => {
    //     let xusdt = await XUSDT.deployed();
    //     const usdtAddress = await xusdt.token();
    //     const usdtContract = new web3.eth.Contract(usdtABI, usdtAddress);

    //     console.log(await usdtContract.methods.balanceOf(alice).call());
    //     // await usdtContract.methods.approve(xusdt.address, 10000000).send({
    //     //     from: alice
    //     // });
    //     // const allowaneAmount = await usdtContract.methods.allowance(alice, xusdt.address);
    //     // console.log('allowance:', allowaneAmount.toString());

    //     await xusdt.withdraw(10000000, {from: alice});
    // })
})