pragma solidity ^0.5.0;
interface FortubeToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
}