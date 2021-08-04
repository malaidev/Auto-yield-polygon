/**
 *Submitted for verification at Etherscan.io on 2020-02-06
*/

// File: @openzeppelin\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

// File: @openzeppelin\contracts\GSN\Context.sol

pragma solidity ^0.5.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin\contracts\math\SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin\contracts\utils\Address.sol

pragma solidity ^0.5.5;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * IMPORTANT: It is unsafe to assume that an address for which this
     * function returns false is an externally-owned account (EOA) and not a
     * contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    /**
     * @dev Converts an `address` into `address payable`. Note that this is
     * simply a type cast: the actual underlying value is not changed.
     *
     * _Available since v2.4.0._
     */
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     *
     * _Available since v2.4.0._
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

interface APRWithPoolOracle {

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


contract IEarnAPRWithPool is Ownable {
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
        addAToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x8dF3aad3a84da6b69A4DA8aeC3eA40d9091B2Ac4); //aMATIC
        addAToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0x60D55F02A771d515e077c9C2403a1ef324885CeC); //aUSDT
        addAToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x1a13F4Ca1d028320A707D99520AbFefca3998b7F); //aUSDC
        addAToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0x1d2a0E5EC8E5bBDCA5CB219e649B565d8e5c3360); //aAAVE
        addAToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x5c2ed810328349100A66B82b78a1791B101C9D61); //aWBTC

        addFToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x949cc03E43C24A954BAa963A00bfC5ab146c6CE7); //fMATIC
        // addFToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0x18D755c981A550B0b8919F1De2CDF882f489c155); //fUSDT
        addFToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0x2E1A74a16e3a9F8e3d825902Ab9fb87c606cB13f); //fUSDC
        // addFToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B, 0xf009c28b2D9E13886105714B895f013E2e43EE12); //fAAVE        
        addFToken(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, 0x97eBF27d40D306aD00bb2922E02c58264b295a95); //fWBTC

        addFTToken(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270, 0x33d6D5F813BF78163901b1e72Fb1fEB90E72fD72); //ftMatic
        addFTToken(0xc2132D05D31c914a87C6611C10748AEb04B58e8F, 0xE2272A850188B43E94eD6DF5b75f1a2FDcd5aC26); //ftUSDT
        addFTToken(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, 0xf330b39f74e7f71ab9604A5307690872b8125aC8); //ftUSDC
        // addFTToken(0xD6DF932A45C0f255f85145f286eA0b292B21C90B,0xf330b39f74e7f71ab9604A5307690872b8125aC8); //ftAAVE
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
        _fulcrum = APRWithPoolOracle(APR).getFulcrumAPRAdjusted(addr, _supply);
      }
      addr = aave[_token];
      if (addr != address(0)) {
        _aave = APRWithPoolOracle(APR).getAaveAPRAdjusted(addr);
      }
      addr = fortube[_token];
      if (addr != address(0)) {
        _fortube = APRWithPoolOracle(APR).getFortubeAPRAdjusted(addr);
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
        xTokens[token] = xToken;
    }

    function addFTToken(
      address token,
      address ftToken
    ) public onlyOwner {
        fortube[token] = ftToken;
    }
}