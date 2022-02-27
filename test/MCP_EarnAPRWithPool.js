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

contract('test EarnAPRWithPool', async([alice, bob, admin, dev, minter]) => {

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
        await this.earnAPRWithPool.set_new_APR(this.aprWithPoolOracle.address)
        await this.mcpContract.set_new_APR(this.earnAPRWithPool.address)

        let mcp = this.mcpContract

        await aaveContract.methods.approve(mcp.address, 10000000).send({
            from: alice
        });

        await mcp.deposit(10000000, {from: alice});
        console.log('---ended-before---');
    });

    it('recommend test', async() => {
        let aprWithPoolOracle = this.aprWithPoolOracle;
        let earnAPRWithPool = this.earnAPRWithPool;
        let mcp = this.mcpContract;
        let statbleTokenAddress = await mcp.token();
        await earnAPRWithPool.set_new_APR(aprWithPoolOracle.address)
        await mcp.set_new_APR(earnAPRWithPool.address)

        var atoken = await earnAPRWithPool.aave(statbleTokenAddress);
        const aave_rate = await aprWithPoolOracle.getAaveAPRAdjusted(atoken);
        console.log(aave_rate.toString());

        var ftoken = await earnAPRWithPool.fulcrum(statbleTokenAddress);
        const fulcrum_rate = await aprWithPoolOracle.getFulcrumAPRAdjusted(ftoken, 0)
        console.log(fulcrum_rate.toString());

    })
})