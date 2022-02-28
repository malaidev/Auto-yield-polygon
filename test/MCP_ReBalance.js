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

contract('test rebalance', async([alice, bob, admin, dev, minter]) => {

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

        let mcp = this.mcpContract

        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.mcpContract.set_new_APR(this.earnAPRWithPool.address)

        await aaveContract.methods.approve(mcp.address, 10000000).send({
            from: alice
        });

        await aaveContract.methods.transfer(mcp.address, 10000000).send({
            from: alice
        });

        console.log('---ended-before---');
    });


    it('test rebalance', async() => {
        let mcp = this.mcpContract;

        let aave_balance = await mcp.balanceAave();
        console.log('before_aave_balance', aave_balance.toString());
        let fulcrum_balance = await mcp.balanceFulcrum();
        console.log('before_fulcrum_balance', fulcrum_balance.toString());

        await mcp.supplyAave(1000);
        aave_balance = await mcp.balanceAave();
        console.log('aave_balance', aave_balance.toString());
        await mcp.supplyFulcrum(1000);
        fulcrum_balance = await mcp.balanceFulcrum();
        console.log('fulcrum_balance', fulcrum_balance.toString());        

        await mcp.rebalance();

        const provider = await mcp.provider();
        console.log(provider.toString());

        console.log('current_balance', await mcp.balance());

        aave_balance = await mcp.balanceAave();
        console.log('current_aave_balance', aave_balance.toString());
        fulcrum_balance = await mcp.balanceFulcrum();
        console.log('current_fulcrum_balance', fulcrum_balance.toString());
    })
});