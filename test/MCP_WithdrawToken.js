const { BN, ether, balance } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

const APRWithPoolOracle = artifacts.require('APRWithPoolOracle')
const EarnAPRWithPool = artifacts.require('EarnAPRWithPool')
const mcp = artifacts.require('MCP')
const ForceSend = artifacts.require('ForceSend');
const aaveABI = require('./abi/aave');

const aaveAddress = '0xD6DF932A45C0f255f85145f286eA0b292B21C90B';
const aaveContract = new web3.eth.Contract(aaveABI, aaveAddress);
const aaveOwner = '0x65b1b96bd01926d3d60dd3c8bc452f22819443a9';

contract('test withdraw xtoken', async([alice, bob, admin, dev, minter]) => {

    before(async () => {

        this.mcpContract = await MCP.new({
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
        await aaveContract.methods.transfer(bob, '10000000000').send({ from: aaveOwner});
        await aaveContract.methods.transfer(minter, '10000000000').send({ from: aaveOwner});
        await aaveContract.methods.transfer(dev, '10000000000').send({ from: aaveOwner});
        
        let mpc = this.mcpContract

        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.mcpContract.set_new_APR(this.earnAPRWithPool.address)

        await aaveContract.methods.transfer(mcp.address, 10000).send({
            from: admin
        });

    });

    it('test withdraw', async() => {
        let mcp = this.mcpContract;     
        await aaveContract.methods.approve(mcp.address, 100000).send({
            from: admin
        }); 
        await aaveContract.methods.approve(mcp.address, 10000000).send({
            from: alice
        });

        await aaveContract.methods.approve(mcp.address, 48457).send({
            from: dev
        }); 
        await aaveContract.methods.approve(mcp.address, 1000).send({
            from: minter
        });

        await aaveContract.methods.approve(mcp.address, 458937489).send({
            from: bob
        });

        await mcp.deposit(100000, {from: admin});
        await mcp.deposit(48457, {from: dev});
        await mcp.deposit(1000, {from: minter});
        await mcp.deposit(458937489, {from: bob});
        await mcp.deposit(10000000, {from: alice});


        fee_address = '0x67926b0C4753c42b31289C035F8A656D800cD9e7'
        mcp.set_new_fee_address(fee_address);
        console.log('before_mcp_balance',await mcp.balance());
        console.log('before_alice_balance',await aaveContract.methods.balanceOf(alice).call());
        // await mcp.supplyAave(1000);
        // let aave_balance = await mcp.balanceAave();
        // console.log('before_aave_balance', aave_balance.toString());
        // console.log('mcp_balance',await mcp.balance());
        let tokenAmount = await mcp.balanceOf(alice);
        console.log('------------', tokenAmount.toString());
        await mcp.rebalance();
        let provider = await mcp.provider();
        console.log('provider',provider.toString());
        await mcp.withdraw(tokenAmount.toString());
        console.log('after_mcp_balance',await mcp.balance());
        console.log('after_alice_balance',await aaveContract.methods.balanceOf(alice).call());
        console.log('fee_address_balance', await aaveContract.methods.balanceOf(fee_address).call());
    })
})