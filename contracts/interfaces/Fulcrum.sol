// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
interface Fulcrum {
    function mint(address receiver, uint256 amount) external payable returns (uint256 mintAmount);
    function burn(address receiver, uint256 burnAmount) external returns (uint256 loanAmountPaid);
    function assetBalanceOf(address _owner) external view returns (uint256 balance);
}