// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
// For test suite
contract ForceSend {
    function go(address payable victim) external payable {
        selfdestruct(victim);
    }
}