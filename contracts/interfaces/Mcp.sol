// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
interface Mcp {
    function deposit(address _reserve, uint256 _amount, address onBehalfOf, uint16 _referralCode) external;
    function withdraw(address _token, uint256 _amount, address _to) external returns(uint256);
}