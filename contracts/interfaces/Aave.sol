pragma solidity ^0.5.0;
interface Aave {
    function deposit(address _reserve, uint256 _amount, address onBehalfOf, uint16 _referralCode) external;
    function withdraw(address _token, uint256 _amount, address _to) external;
}