pragma solidity ^0.5.0;
interface LendingPoolAddressesProvider {
    function getLendingPool() external view returns (address);
    function getLendingPoolCollateralManager() external view returns (address);
}