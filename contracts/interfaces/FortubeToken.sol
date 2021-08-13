pragma solidity ^0.5.0;
interface FortubeToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function ONE() external view returns (uint256);
    function exchangeRateStored() external view returns (uint256);
    function divExp(uint a, uint b) external view returns (uint256);
    function mulExp(uint a, uint b) external view returns (uint256);
}