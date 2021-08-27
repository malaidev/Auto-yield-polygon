// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
interface FortubeToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function ONE() external view returns (uint256);
    function exchangeRateStored() external view returns (uint256);
}