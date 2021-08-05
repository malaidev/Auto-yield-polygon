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

interface IProtocalProvider {
    function ADDRESSES_PROVIDER() external view returns (address);
    function getReserveData(
        address asset
    )
    external
    view
    returns (uint256 availableLiquidity, uint256 totalStableDebt, uint256 totalVariableDebt, uint256 liquidityRate, uint256 variableBorrowRate, uint256 stableBorrowRate, uint256 averageStableBorrowRate, uint256 liquidityIndex, uint256 variableBorrowIndex, uint40 lastUpdateTimestamp);
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

  address public AAVE;
  address public protocalProvider;
//   address public DefaultReserveInterestRateStrategy;

  uint256 public liquidationRatio;

  constructor() public {
    AAVE = address(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);
    protocalProvider = address(0x7551b5D2763519d4e37e8B81929D336De671d46d);
    // DefaultReserveInterestRateStrategy = address(0x5C2B160B9248249ccC0492D566903FB2F8682E39);
    liquidationRatio = 50000000000000000;
  }

  function set_new_AAVE(address _new_AAVE) public onlyOwner {
      AAVE = _new_AAVE;
  }
  function set_new_Ratio(uint256 _new_Ratio) public onlyOwner {
      liquidationRatio = _new_Ratio;
  }
  function getFulcrumAPRAdjusted(address token, uint256 _supply) public view returns(uint256) {
    return IFulcrum(token).nextSupplyInterestRate(_supply).div(100);
  }

  function getAaveAPRAdjusted(address token) public view returns (uint256) {
    IProtocalProvider provider = IProtocalProvider(protocalProvider);
    (,,,uint256 liquidityRate,,,,,,) = provider.getReserveData(token);
    return liquidityRate;
  }
  function getFortubeAPRAdjusted(address token) public view returns (uint256) {
    IFortube fortube = IFortube(token);
    return fortube.APY();
  }
}
// interestRateStrategyAddress