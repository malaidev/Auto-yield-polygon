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

contract('test withdraw xtoken', async([alice, bob, admin, dev, minter]) => {

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
        
        await usdtContract.methods.transfer(alice, '10000000000').send({ from: usdtOwner});
        
        let xusdt = this.xusdtContract

        await usdtContract.methods.approve(xusdt.address, 10000000).send({
            from: alice
        });

        await xusdt.deposit(10000000, {from: alice});

        let statbleTokenAddress = await this.xusdtContract.token();
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xusdtContract.set_new_APR(this.earnAPRWithPool.address)
        await this.earnAPRWithPool.addXToken(statbleTokenAddress, this.xusdtContract.address);

    });

    it('test withdraw', async() => {
        // let xusdt = await XUSDT.deployed();
        let xusdt = this.xusdtContract;
        console.log('before_xusdt_balance',await xusdt.balance());
        console.log('before_alice_balance',await usdtContract.methods.balanceOf(alice).call());
        // await xusdt.supplyAave(1000);
        // let aave_balance = await xusdt.balanceAave();
        // console.log('before_aave_balance', aave_balance.toString());
        console.log('xusdt_balance',await xusdt.balance());
        let tokenAmount = await xusdt.balanceOf(alice);
        console.log('------------', tokenAmount.toString());
        await xusdt.rebalance();
        await xusdt.withdraw(tokenAmount.toString());
        console.log('after_xusdt_balance',await xusdt.balance());
        console.log('after_alice_balance',await usdtContract.methods.balanceOf(alice).call());
    })
})