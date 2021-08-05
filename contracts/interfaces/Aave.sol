pragma solidity ^0.5.0;
interface Aave {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external;
}