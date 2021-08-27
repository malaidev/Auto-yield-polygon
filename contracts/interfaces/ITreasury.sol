// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
interface ITreasury {
    function depositToken(address _token) external payable;
}