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

contract('test withdraw xtoken', async([alice, bob, admin, dev, minter]) => {

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
        await aaveContract.methods.transfer(admin, '10000000000').send({ from: aaveOwner});
        
        let xaave = this.xaaveContract

        await aaveContract.methods.approve(xaave.address, 10000000).send({
            from: alice
        });

        await aaveContract.methods.approve(xaave.address, 10000000000).send({
            from: admin
        });

        await xaave.deposit(10000000, {from: alice});
        await xaave.deposit(10000000000, {from: admin});

        let statbleTokenAddress = await this.xaaveContract.token();
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.xaaveContract.set_new_APR(this.earnAPRWithPool.address)
        await this.earnAPRWithPool.addXToken(statbleTokenAddress, this.xaaveContract.address);

    });

    it('test withdraw', async() => {
        // let xaave = await XAAVE.deployed();
        let xaave = this.xaaveContract;
        fee_address = '0x3F58d9e9E74990bf38578043F7332444C9624561'
        xaave.set_new_fee_address(fee_address);
        console.log('before_xaave_balance',await xaave.balance());
        console.log('before_alice_balance',await aaveContract.methods.balanceOf(alice).call());
        // await xaave.supplyAave(1000);
        // let aave_balance = await xaave.balanceAave();
        // console.log('before_aave_balance', aave_balance.toString());
        console.log('xaave_balance',await xaave.balance());
        let tokenAmount = await xaave.balanceOf(alice);
        console.log('------------', tokenAmount.toString());
        await xaave.rebalance();
        let provider = await xaave.provider();
        console.log('provider',provider.toString());
        await xaave.withdraw(tokenAmount.toString());
        console.log('after_xaave_balance',await xaave.balance());
        console.log('after_alice_balance',await aaveContract.methods.balanceOf(alice).call());
        console.log('fee_address_balance', await aaveContract.methods.balanceOf(fee_address).call());
    })
})