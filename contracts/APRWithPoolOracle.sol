pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import './libraries/Context.sol';
import './libraries/Ownable.sol';
import './libraries/SafeMath.sol';
import './libraries/Decimal.sol';
import './libraries/Address.sol';
import './interfaces/IERC20.sol';

// Fulcrum
interface IFulcrum {
  function supplyInterestRate() external view returns (uint256);
  function nextSupplyInterestRate(uint256 supplyAmount) external view returns (uint256);
}

// interface LendingPoolAddressesProvider {
//     function getLendingPoolCollateralManager() external view returns (address);
// }

interface IFortube {
    function APY() external view returns (uint256);
}


interface IProtocolProvider {
    function ADDRESSES_PROVIDER() external view returns (address);
    function getReserveData(
        address token
    )
    external
    view
    returns (uint256 availableLiquidity, uint256 totalStableDebt, uint256 totalVariableDebt, uint256 liquidityRate, uint256 variableBorrowRate, uint256 stableBorrowRate, uint256 averageStableBorrowRate, uint256 liquidityIndex, uint256 variableBorrowIndex, uint40 lastUpdateTimestamp);
}

//manual-review/APRWithPoolOracle
interface ILendingPoolAddressesProvider{
  function getAddress(bytes32 id) external view returns (address);
}

contract Structs {
  struct Asset {
    address lendingPool;
    address priceOralce;
    address interestModel;
  }
}

contract APRWithPoolOracle is Ownable, Structs {
  using SafeMath for uint256;
  using Address for address;

  uint256 DECIMAL = 10 ** 18;

  address immutable public AAVE;
  address public protocolProvider;

  constructor() public {
    AAVE = address(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);
    protocolProvider = ILendingPoolAddressesProvider(AAVE).getAddress('0x1'); //manual-review/APRWithPoolOracle
  }

  function getFulcrumAPRAdjusted(address token, uint256 _supply) public view returns(uint256) {
    if(token == address(0))
      return 0;
    else
      return IFulcrum(token).nextSupplyInterestRate(_supply).mul(1e7); // normalize all apy's of aave, fulcrum, fortube :manual-review/APRWithPoolOracle
  }

  function getAaveAPRAdjusted(address token) public view returns (uint256) {
    if(token == address(0))
      return 0;
    else{
      IProtocolProvider provider = IProtocolProvider(protocolProvider);
      (,,,uint256 liquidityRate,,,,,,) = provider.getReserveData(token);
      return liquidityRate;
    }
  }
  function getFortubeAPRAdjusted(address token) public view returns (uint256) {
    if(token == address(0))
      return 0;
    else{
      IFortube fortube = IFortube(token);
      return fortube.APY().mul(1e9);    // normalize all apy's of aave, fulcrum, fortube :manual-review/APRWithPoolOracle
    }
  }
}