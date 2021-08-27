// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCollateralManager() external view returns (address);
}