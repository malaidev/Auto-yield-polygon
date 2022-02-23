// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;

import './libraries/Context.sol';
import './libraries/Ownable.sol';
import './interfaces/IERC20.sol';
import './libraries/SafeMath.sol';
import './libraries/Decimal.sol';
import './libraries/Address.sol';

interface IAPRWithPoolOracle {

  function getFulcrumAPR(address token) external view returns(uint256);
  function getFulcrumAPRAdjusted(address token, uint256 _supply) external view returns(uint256);
  function getAaveCore() external view returns (address);
  function getAaveAPR(address token) external view returns (uint256);
  function getAaveAPRAdjusted(address token) external view returns (uint256);
  function getFortubeAPRAdjusted(address token) external view returns (uint256);

}

interface IUniswapFactory {
    function getExchange(address token) external view returns (address exchange);
}

interface IxToken {
  function calcPoolValueInToken() external view returns (uint256);
  function decimals() external view returns (uint256);
}


contract EarnAPRWithPool is Ownable {
    using SafeMath for uint;
    using Address for address;

    mapping(address => uint256) public pools;
    mapping(address => address) public fulcrum;
    mapping(address => address) public aave;
    mapping(address => address) public fortube;

    address public APR;

    constructor() public {
        APR = address(0x0bCf5B3603fe34428Ac460C52674F12517d7C9aE);

        addFToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x949cc03E43C24A954BAa963A00bfC5ab146c6CE7); //fMATIC
        addFToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0x18D755c981A550B0b8919F1De2CDF882f489c155); //fUSDT
        addFToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x2E1A74a16e3a9F8e3d825902Ab9fb87c606cB13f); //fUSDC
        addFToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0xf009c28b2D9E13886105714B895f013E2e43EE12); //fAAVE
        addFToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x97eBF27d40D306aD00bb2922E02c58264b295a95); //fWBTC

        addFTToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x33d6D5F813BF78163901b1e72Fb1fEB90E72fD72); //ftMatic
        addFTToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0xE2272A850188B43E94eD6DF5b75f1a2FDcd5aC26); //ftUSDT
        addFTToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0xf330b39f74e7f71ab9604A5307690872b8125aC8); //ftUSDC
        addFTToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x57160962Dc107C8FBC2A619aCA43F79Fd03E7556); //ftWBTC
        
        // LendingPoolAddressesProvider requires asset address for apy
        addAToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270); //aMATIC
        addAToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0xc2132D05D31c914a87C6611C10748AEb04B58e8F); //aUSDT
        addAToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174); //aUSDC
        addAToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0xD6DF932A45C0f255f85145f286eA0b292B21C90B); //aAAVE
        addAToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6); //aWBTC
    }

    // Wrapper for legacy v1 token support
    function recommend(address _token) public view returns (
      string memory choice,
      uint256 fapr,
      uint256 aapr,
      uint256 ftapr
    ) {
      (fapr,aapr,ftapr) = getAPROptionsInc(_token);
      return (choice, fapr, aapr, ftapr);
    }

    function getAPROptionsInc(address _token) public view returns (
      uint256 _fulcrum,
      uint256 _aave,
      uint256 _fortube
    ) {

      address addr;
      addr = fulcrum[_token];
      if (addr != address(0)) {
        _fulcrum = IAPRWithPoolOracle(APR).getFulcrumAPRAdjusted(addr, 0);
      }
      addr = aave[_token];
      if (addr != address(0)) {
        _aave = IAPRWithPoolOracle(APR).getAaveAPRAdjusted(addr);
      }
      addr = fortube[_token];
      if (addr != address(0)) {
        _fortube = IAPRWithPoolOracle(APR).getFortubeAPRAdjusted(addr);
      }

      return (
        _fulcrum,
        _aave,
        _fortube
      );
    }

    function addFToken(
      address token,
      address fToken
    ) public onlyOwner {
        require(fulcrum[token] == address(0), "This token is already set.");
        fulcrum[token] = fToken;
    }

    function addAToken(
      address token,
      address aToken
    ) public onlyOwner {
        aave[token] = aToken;
    }

    function addFTToken(
      address token,
      address ftToken
    ) public onlyOwner {
        require(fortube[token] == address(0), "This token is already set.");
        fortube[token] = ftToken;
    }

    function set_new_APR(address _new_APR) public onlyOwner {
        APR = _new_APR;
    }
}