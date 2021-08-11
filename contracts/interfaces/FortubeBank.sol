pragma solidity ^0.5.0;
interface FortubeBank {
    function deposit(address token, uint256 amount) external payable;
    function withdraw(address underlying, uint256 withdrawTokens) external returns (uint256);
    function controller() external returns (address);
}