pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint8);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function divCeil(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (uint256)
    {
        uint256 quotient = div(a, b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Decimal {
    using SafeMath for uint256;

    uint256 constant BASE = 10**18;

    function one()
        internal
        pure
        returns (uint256)
    {
        return BASE;
    }

    function onePlus(
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {
        return d.add(BASE);
    }

    function mulFloor(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {
        return target.mul(d) / BASE;
    }

    function mulCeil(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {
        return target.mul(d).divCeil(BASE);
    }

    function divFloor(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {
        return target.mul(BASE).div(d);
    }

    function divCeil(
        uint256 target,
        uint256 d
    )
        internal
        pure
        returns (uint256)
    {
        return target.mul(BASE).divCeil(d);
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

// Fulcrum
interface Fulcrum {
  function supplyInterestRate() external view returns (uint256);
  function nextSupplyInterestRate(uint256 supplyAmount) external view returns (uint256);
}

interface LendingPoolAddressesProvider {
    function getLendingPoolCollateralManager() external view returns (address);
}

// interface IDefaultReserveInterestRateStrategy {

//     function calculateInterestRates(
//         address _reserve,
//         uint256 _availableLiquidity,
//         uint256 _totalStableDebt,
//         uint256 _totalVariableDebt,
//         uint256 _averageStableBorrowRate,
//         uint256 _reserveFactor)
//     external
//     view
//     returns (uint256 liquidityRate, uint256 stableBorrowRate, uint256 variableBorrowRate);
// }

interface IProtocalProvider {
    function getReserveData(
        address asset
    )
    external
    view
    returns (uint256 availableLiquidity, uint256 totalStableDebt, uint256 totalVariableDebt, uint256 liquidityRate, uint256 variableBorrowRate, uint256 variableBorrowRate, uint256 stableBorrowRate, uint256 averageStableBorrowRate, uint256 liquidityIndex, uint256 variableBorrowIndex, uint40 lastUpdateTimestamp);
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
    return Fulcrum(token).nextSupplyInterestRate(_supply).div(100);
  }

  function getAaveAPRAdjusted(address token, uint256 _supply) public view returns (uint256) {
    // LendingPoolCore core = LendingPoolCore(LendingPoolAddressesProvider(AAVE).getLendingPoolCollateralManager()); //getLendingPoolCore
    // IReserveInterestRateStrategy apr = IReserveInterestRateStrategy(core.getReserveInterestRateStrategyAddress(token));
    // (uint256 newLiquidityRate,,) = apr.calculateInterestRates(
    //   token,
    //   core.getReserveAvailableLiquidity(token).add(_supply),
    //   core.getReserveTotalBorrowsStable(token),
    //   core.getReserveTotalBorrowsVariable(token),
    //   core.getReserveCurrentAverageStableBorrowRate(token)
    // );
    IProtocalProvider provider = IProtocalProvider(protocalProvider);
    (,,,uint256 newLiquidityRate,,,,,,,) = provider.getReserveData(token);
    // IDefaultReserveInterestRateStrategy apr = IDefaultReserveInterestRateStrategy(DefaultReserveInterestRateStrategy);
    // (uint256 newLiquidityRate,,) = apr.calculateInterestRates(
    //     token,
    //     provider.getReserveData(token).availableLiquidity,
    //     provider.getReserveData(token).totalStableDebt,
    //     provider.getReserveData(token).totalVariableDebt,
    //     provider.getReserveData(token).availableLiquidity,
    //     provider.getReserveData(token).availableLiquidity,
    //     provider.getReserveData(token).availableLiquidity
    // );
    return newLiquidityRate.div(1e9);
  }
}
// interestRateStrategyAddress