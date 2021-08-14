pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import './libraries/Context.sol';
import './libraries/Ownable.sol';
import './interfaces/IERC20.sol';
import './libraries/SafeMath.sol';
import './libraries/Decimal.sol';
import './libraries/Address.sol';
import './libraries/SafeERC20.sol';
import './libraries/ReentrancyGuard.sol';
import './libraries/ERC20.sol';
import './libraries/ERC20Detailed.sol';
import './libraries/TokenStructs.sol';
import './interfaces/Aave.sol';
import './interfaces/AToken.sol';
import './interfaces/Fulcrum.sol';
import './interfaces/IIEarnManager.sol';
import './interfaces/LendingPoolAddressesProvider.sol';
import './interfaces/ITreasury.sol';

contract xAAVE is ERC20, ERC20Detailed, ReentrancyGuard, Ownable, TokenStructs {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  uint256 public pool;
  address public token;
  address public fulcrum;
  address public aave;
  address public aaveToken;
  address public apr;
  address public FEE_ADDRESS;
  uint256 public feeAmount;

  mapping (address => uint256) depositedAmount;

  enum Lender {
      NONE,
      AAVE,
      FULCRUM
  }

  Lender public provider = Lender.NONE;

  constructor () public ERC20Detailed("xend AAVE", "xAAVE", 18) {
    //mumbai network
    // token = address(0x57baea64620d5b7254fff6976859a53d4b71d950);
    // apr = address(0xCC7986A6a8A0774070868Cf0D4aCe451DbEC76EF);
    // aave = address(0x178113104fEcbcD7fF8669a0150721e231F0FD4B);
    // fulcrum = address(0xf009c28b2d9e13886105714b895f013e2e43ee12);
    // aaveToken = address(0x7ec62b6fC19174255335C8f4346E0C2fcf870a6B);
    
    token = address(0xD6DF932A45C0f255f85145f286eA0b292B21C90B);
    apr = address(0xdD6d648C991f7d47454354f4Ef326b04025a48A8);
    aave = address(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);
    fulcrum = address(0xf009c28b2D9E13886105714B895f013E2e43EE12);
    aaveToken = address(0x1d2a0E5EC8E5bBDCA5CB219e649B565d8e5c3360);
    
    FEE_ADDRESS = address(0xfa4002f80A366d1829Be3160Ac7f5802dE5EEAf4);
    feeAmount = 0;
    approveToken();
  }

  // Ownable setters incase of support in future for these systems
  function set_new_APR(address _new_APR) public onlyOwner {
      apr = _new_APR;
  }
  function set_new_feeAmount(uint256 fee) public onlyOwner{
    feeAmount = fee;
  }
  function set_new_fee_address(address _new_fee_address) public onlyOwner {
      FEE_ADDRESS = _new_fee_address;
  }
  // Quick swap low gas method for pool swaps
  function deposit(uint256 _amount)
      external
      nonReentrant
  {
      require(_amount > 0, "deposit must be greater than 0");
      rebalance();
      pool = _calcPoolValueInToken();

      IERC20(token).transferFrom(msg.sender, address(this), _amount);

      // Calculate pool shares
      uint256 shares = 0;
      if (pool == 0) {
        shares = _amount;
        pool = _amount;
      } else {
        shares = (_amount.mul(_totalSupply)).div(pool);
      }
      pool = _calcPoolValueInToken();
      _mint(msg.sender, shares);
      depositedAmount[msg.sender] = depositedAmount[msg.sender].add(_amount);
      emit Deposit(msg.sender, _amount);
  }

  // No rebalance implementation for lower fees and faster swaps
  function withdraw(uint256 _shares)
      external
      nonReentrant
  {
      require(_shares > 0, "withdraw must be greater than 0");

      uint256 ibalance = balanceOf(msg.sender);
      require(_shares <= ibalance, "insufficient balance");

      // Could have over value from xTokens
      pool = _calcPoolValueInToken();
      // Calc to redeem before updating balances
      uint256 r = (pool.mul(_shares)).div(_totalSupply);


      _balances[msg.sender] = _balances[msg.sender].sub(_shares, "redeem amount exceeds balance");
      _totalSupply = _totalSupply.sub(_shares);

      emit Transfer(msg.sender, address(0), _shares);

      // Check balance
      uint256 b = IERC20(token).balanceOf(address(this));
      if (b < r) {
        _withdrawSome(r.sub(b));
      }

      uint256 fee = (r.sub(depositedAmount[msg.sender])).mul(feeAmount).div(1000);
      if(fee > 0){
        IERC20(token).approve(FEE_ADDRESS, fee);
        ITreasury(FEE_ADDRESS).depositToken(token);
      }
      IERC20(token).transfer(msg.sender, r.sub(fee));
      depositedAmount[msg.sender] = depositedAmount[msg.sender].sub(r);
      rebalance();
      pool = _calcPoolValueInToken();
      emit Withdraw(msg.sender, _shares);
  }

  function() external payable {

  }

  function recommend() public view returns (Lender) {
    (, uint256 fapr, uint256 aapr, ) = IIEarnManager(apr).recommend(token);
    uint256 max = 0;
    if (fapr > max) {
      max = fapr;
    }
    if (aapr > max) {
      max = aapr;
    } 
    Lender newProvider = Lender.NONE;
    if (max == aapr) {
      newProvider = Lender.AAVE;
    } else if (max == fapr) {
      newProvider = Lender.FULCRUM;
    }
    return newProvider;
  }

  function balance() public view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  function getAave() public view returns (address) {
    return LendingPoolAddressesProvider(aave).getLendingPool();
  }

  function getDepositedAmount(address investor) public view returns (uint256) {
    return depositedAmount[investor];
  }

  function approveToken() public {
      IERC20(token).approve(getAave(), uint(-1));
      IERC20(token).approve(fulcrum, uint(-1));
  }

  function balanceFulcrumInToken() public view returns (uint256) {
    uint256 b = balanceFulcrum();
    if (b > 0) {
      b = Fulcrum(fulcrum).assetBalanceOf(address(this));
    }
    return b;
  }
  function balanceFulcrum() public view returns (uint256) {
    return IERC20(fulcrum).balanceOf(address(this));
  }
  function balanceAave() public view returns (uint256) {
    return IERC20(aaveToken).balanceOf(address(this));
  }

  function _balance() internal view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  function _balanceFulcrumInToken() internal view returns (uint256) {
    uint256 b = balanceFulcrum();
    if (b > 0) {
      b = Fulcrum(fulcrum).assetBalanceOf(address(this));
    }
    return b;
  }

  function _balanceFulcrum() internal view returns (uint256) {
    return IERC20(fulcrum).balanceOf(address(this));
  }
  function _balanceAave() internal view returns (uint256) {
    return IERC20(aaveToken).balanceOf(address(this));
  }

  function _withdrawAll() internal {
    uint256  amount = _balanceFulcrum();
    if (amount > 0) {
      _withdrawFulcrum(amount);
    }
    amount = _balanceAave();
    if (amount > 0) {
      _withdrawAave(amount);
    }
  }

  function _withdrawSomeFulcrum(uint256 _amount) internal {
    uint256 b = balanceFulcrum();
    // Balance of token in fulcrum
    uint256 bT = balanceFulcrumInToken();
    require(bT >= _amount, "insufficient funds");
    // can have unintentional rounding errors
    uint256 amount = (b.mul(_amount)).div(bT).add(1);
    _withdrawFulcrum(amount);
  }

  function _withdrawSome(uint256 _amount) internal {
    if (provider == Lender.AAVE) {
      require(balanceAave() >= _amount, "insufficient funds");
      _withdrawAave(_amount);
    }
    if (provider == Lender.FULCRUM) {
      _withdrawSomeFulcrum(_amount);
    }
  }

  function rebalance() public {
    Lender newProvider = recommend();

    if (newProvider != provider) {
      _withdrawAll();
    }

    if (balance() > 0) {
      if (newProvider == Lender.FULCRUM) {
        supplyFulcrum(balance());
      } else if (newProvider == Lender.AAVE) {
        supplyAave(balance());
      } 
    }

    provider = newProvider;
  }

  // Internal only rebalance for better gas in redeem
  function _rebalance(Lender newProvider) internal {
    if (_balance() > 0) {
      if (newProvider == Lender.FULCRUM) {
        supplyFulcrum(_balance());
      } else if (newProvider == Lender.AAVE) {
        supplyAave(_balance());
      } 
    }
    provider = newProvider;
  }

  function supplyAave(uint amount) public {
      Aave(getAave()).deposit(token, amount, address(this), 0);
  }
  function supplyFulcrum(uint amount) public {
      require(Fulcrum(fulcrum).mint(address(this), amount) > 0, "FULCRUM: supply failed");
  }

  function _withdrawAave(uint amount) internal {
      Aave(getAave()).withdraw(token, amount, address(this));
  }
  function _withdrawFulcrum(uint amount) internal {
      require(Fulcrum(fulcrum).burn(address(this), amount) > 0, "FULCRUM: withdraw failed");
  }

  function _calcPoolValueInToken() internal view returns (uint) {
    return _balanceFulcrumInToken()
      .add(_balanceAave())
      .add(_balance());
  }

  function calcPoolValueInToken() public view returns (uint) {

    return balanceFulcrumInToken()
      .add(balanceAave())
      .add(balance());
  }

  function getPricePerFullShare() public view returns (uint) {
    uint _pool = calcPoolValueInToken();
    return _pool.mul(1e18).div(_totalSupply);
  }
}