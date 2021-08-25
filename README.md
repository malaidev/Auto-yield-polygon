## DOCUMENTATION

Polygon Earn is an automated yield aggregator on Polygon designed to automatically seek the best yield from DeFi protocols by automatically shifting funds across  protocols to the protocol with the highest yield. 

This ensures that users don’t have to have to manually check for protocols with the highest APYs. Our smart contracts perform all these operations automatically.

We are using 3 lending protocols on Polygon mainnet(AAVE, Fulcrum and ForTube). Our protocol design pattern allows us to dynamically add new protocols without breaking the original design.

## Polygon Earn - Smart Contract Operations:

![Operation_img](https://github.com/xendfinance/polygon-earn/blob/main/operations.png)

### 1. Deposit
* Selects lending provider
Gets APYs from lending protocols and selects max APY from them.
Sets a new lending provider with it.
*Withdraws all token balances from lending protocols and supplies them to the new provider( lending protocol with max APY).

### 2. Withdraw
* Checks balance
If the balance is enough, withdraw the supported token amount.
* In other cases, if it isn’t enough, withdraw the deficit amount from other lending protocols and send the amount requested by the investor to the investor 

### 3. Rebalance
* Selects a lending provider with max APY and withdraws balances from other lending protocols and then supplies the withdrawn token to selected lending provider with max APY
