/**
 *Submitted for verification at Etherscan.io on 2020-02-06
*/

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.5.0;

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
    mapping(address => address) public xTokens;
    mapping(address => address) public fortube;

    address public APR;

    constructor() public {
        //mumbai
        // APR = address(0x881ffD8f2FF93214805BB00Af07ba49696fDBB8A);

        // addAToken(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889, 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889); //aMATIC
        // addAToken(0xF8744C0bD8C7adeA522d6DDE2298b17284A79D1b, 0xF8744C0bD8C7adeA522d6DDE2298b17284A79D1b); //aUSDT
        // addAToken(0x2271e3Fef9e15046d09E1d78a8FF038c691E9Cf9, 0x2271e3Fef9e15046d09E1d78a8FF038c691E9Cf9); //aUSDC
        // addAToken(0x7ec62b6fC19174255335C8f4346E0C2fcf870a6B, 0x7ec62b6fC19174255335C8f4346E0C2fcf870a6B); //aAAVE
        // addAToken(0xc9276ECa6798A14f64eC33a526b547DAd50bDa2F, 0xc9276ECa6798A14f64eC33a526b547DAd50bDa2F); //aWBTC

        // addXToken(0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889, ); //xMATIC
        // addXToken(0xF8744C0bD8C7adeA522d6DDE2298b17284A79D1b, ); //xUSDT
        // addXToken(0x2271e3Fef9e15046d09E1d78a8FF038c691E9Cf9, ); //xUSDC
        // addXToken(0x7ec62b6fC19174255335C8f4346E0C2fcf870a6B, ); //xAAVE
        // addXToken(0xc9276ECa6798A14f64eC33a526b547DAd50bDa2F, ); //xWBTC

        //mainnet
        APR = address(0x0bCf5B3603fe34428Ac460C52674F12517d7C9aE);
        // addAToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x8dF3aad3a84da6b69A4DA8aeC3eA40d9091B2Ac4); //aMATIC
        // addAToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0x60D55F02A771d515e077c9C2403a1ef324885CeC); //aUSDT
        // addAToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F); //aUSDC
        // addAToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0x1d2a0E5EC8E5bBDCA5CB219e649B565d8e5c3360); //aAAVE
        // addAToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x5c2ed810328349100A66B82b78a1791B101C9D61); //aWBTC

        addAToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270); //aMATIC
        addAToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0xc2132D05D31c914a87C6611C10748AEb04B58e8F); //aUSDT
        addAToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174); //aUSDC
        addAToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0xD6DF932A45C0f255f85145f286eA0b292B21C90B); //aAAVE
        addAToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6); //aWBTC

        addFToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x949cc03E43C24A954BAa963A00bfC5ab146c6CE7); //fMATIC
        addFToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0x18D755c981A550B0b8919F1De2CDF882f489c155); //fUSDT
        addFToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x2E1A74a16e3a9F8e3d825902Ab9fb87c606cB13f); //fUSDC
        addFToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0xf009c28b2D9E13886105714B895f013E2e43EE12); //fAAVE        
        addFToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x97eBF27d40D306aD00bb2922E02c58264b295a95); //fWBTC

        addFTToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x33d6D5F813BF78163901b1e72Fb1fEB90E72fD72); //ftMatic
        addFTToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0xE2272A850188B43E94eD6DF5b75f1a2FDcd5aC26); //ftUSDT
        addFTToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0xf330b39f74e7f71ab9604A5307690872b8125aC8); //ftUSDC
        addFTToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0x0000000000000000000000000000000000000000); //ftAAVE
        addFTToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x57160962Dc107C8FBC2A619aCA43F79Fd03E7556); //ftWBTC
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
      address xToken = xTokens[_token];
      uint256 _supply = 0;
      if (xToken != address(0)) {
        _supply = IxToken(xToken).calcPoolValueInToken();
      }
      return getAPROptionsAdjusted(_token, _supply);
    }

    function getAPROptionsAdjusted(address _token, uint256 _supply) public view returns (
      uint256 _fulcrum,
      uint256 _aave,
      uint256 _fortube
    ) {

      address addr;
      addr = fulcrum[_token];
      if (addr != address(0)) {
        _fulcrum = IAPRWithPoolOracle(APR).getFulcrumAPRAdjusted(addr, _supply);
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
        fulcrum[token] = fToken;
    }

    function addAToken(
      address token,
      address aToken
    ) public onlyOwner {
        aave[token] = aToken;
    }

    function addXToken(
      address token,
      address xToken
    ) public onlyOwner {
      // require(false, 'test');
        xTokens[token] = xToken;
    }

    function addFTToken(
      address token,
      address ftToken
    ) public onlyOwner {
        fortube[token] = ftToken;
    }

    function set_new_APR(address _new_APR) public onlyOwner {
        APR = _new_APR;
    }
}