pragma solidity ^0.5.0;
interface IIEarnManager {
    function recommend(address _token) external view returns (
      string memory choice,
      uint256 fapr,
      uint256 aapr,
      uint256 ftapr
    );
}