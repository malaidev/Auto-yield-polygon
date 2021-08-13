pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import './libraries/Context.sol';
import './libraries/Ownable.sol';
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
import './interfaces/FortubeToken.sol';
import './interfaces/FortubeBank.sol';
import './interfaces/Fulcrum.sol';
import './interfaces/IIEarnManager.sol';
import './interfaces/LendingPoolAddressesProvider.sol';
import './interfaces/IERC20.sol';
import './interfaces/ITreasury.sol';

contract xWBTC is ERC20, ERC20Detailed, ReentrancyGuard, Ownable, TokenStructs {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint256;

  uint256 public pool;
  address public token;
  address public fulcrum;
  address public aave;
  address public aaveToken;
  address public apr;
  address public fortubeToken;
  address public fortubeBank;
  address public FEE_ADDRESS;

  mapping (address => uint256) depositedAmount;

  enum Lender {
      NONE,
      AAVE,
      FULCRUM,
      FORTUBE
  }

  Lender public provider = Lender.NONE;

  constructor () public ERC20Detailed("xend WBTC", "xWTBC", 18) {
    //mumbai network
    // token = address(0xcf6bc4ae4a99c539353e4bf4c80fff296413ceea);
    // apr = address(0xCC7986A6a8A0774070868Cf0D4aCe451DbEC76EF);
    // aave = address(0x178113104fEcbcD7fF8669a0150721e231F0FD4B);
    // fulcrum = address(0x178113104fEcbcD7fF8669a0150721e231F0FD4B);
    // aaveToken = address(0xc9276ECa6798A14f64eC33a526b547DAd50bDa2F);

    token = address(0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6);
    apr = address(0xdD6d648C991f7d47454354f4Ef326b04025a48A8);
    aave = address(0xd05e3E715d945B59290df0ae8eF85c1BdB684744);
    fulcrum = address(0x97eBF27d40D306aD00bb2922E02c58264b295a95);
    aaveToken = address(0x5c2ed810328349100A66B82b78a1791B101C9D61);
    fortubeToken = address(0x57160962Dc107C8FBC2A619aCA43F79Fd03E7556);
    fortubeBank = address(0x170371bbcfFf200bFB90333e799B9631A7680Cc5);

    FEE_ADDRESS = address(0xfa4002f80A366d1829Be3160Ac7f5802dE5EEAf4);
    approveToken();
  } 

  // Ownable setters incase of support in future for these systems
  function set_new_APR(address _new_APR) public onlyOwner {
      apr = _new_APR;
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

      uint256 fee = (r.sub(depositedAmount[msg.sender])).mul(20).div(100);
      if(fee > 0){
        IERC20(token).approve(FEE_ADDRESS, fee);
        ITreasury(FEE_ADDRESS).depositToken(token);
      }
      IERC20(token).transfer(msg.sender, r.sub(fee));
      depositedAmount[msg.sender] = depositedAmount[msg.sender].sub(r);
      pool = _calcPoolValueInToken();
  }

  function() external payable {

  }

  function recommend() public view returns (Lender) {
    (, uint256 fapr,uint256 aapr, uint256 ftapr) = IIEarnManager(apr).recommend(token);
    uint256 max = 0;
    if (fapr > max) {
      max = fapr;
    }
    if (aapr > max) {
      max = aapr;
    }
    if (ftapr > max) {
      max = ftapr;
    }
    Lender newProvider = Lender.NONE;
    if (max == aapr) {
      newProvider = Lender.AAVE;
    } else if (max == fapr) {
      newProvider = Lender.FULCRUM;
    } else if (max == ftapr) {
      newProvider = Lender.FORTUBE;
    }
    return newProvider;
  }

  function balance() public view returns (uint256) {
    return IERC20(token).balanceOf(address(this));
  }

  function getAave() public view returns (address) {
    return LendingPoolAddressesProvider(aave).getLendingPool();
  }

  function approveToken() public {
      IERC20(token).approve(getAave(), uint(-1));
      IERC20(token).approve(fulcrum, uint(-1));
      IERC20(token).approve(FortubeBank(fortubeBank).controller(),  uint(-1));
  }
  function balanceFortubeInToken() public view returns (uint256) {
    uint256 b = balanceFortube();
    if (b > 0) {
      uint256 exchangeRate = FortubeToken(fortubeToken).exchangeRateStored();
      uint256 oneAmount = FortubeToken(fortubeToken).ONE();
      b = FortubeToken(fortubeToken).divExp(FortubeToken(fortubeToken).mulExp(b, exchangeRate), oneAmount);
    }
    return b;
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
  function balanceFortube() public view returns (uint256) {
    return FortubeToken(fortubeToken).balanceOf(address(this));
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

  function _balanceFortubeInToken() internal view returns (uint256) {
    uint256 b = balanceFortube();
    if (b > 0) {
      uint256 exchangeRate = FortubeToken(fortubeToken).exchangeRateStored();
      uint256 oneAmount = FortubeToken(fortubeToken).ONE();
      b = FortubeToken(fortubeToken).divExp(FortubeToken(fortubeToken).mulExp(b, exchangeRate), oneAmount);
    }
    return b;
  }
  function _balanceFulcrum() internal view returns (uint256) {
    return IERC20(fulcrum).balanceOf(address(this));
  }
  function _balanceAave() internal view returns (uint256) {
    return IERC20(aaveToken).balanceOf(address(this));
  }
  function _balanceFortube() internal view returns (uint256) {
    return IERC20(fortubeToken).balanceOf(address(this));
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
    amount = _balanceFortube();
    if (amount > 0) {
      _withdrawFortube(amount);
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

  function _withdrawSomeFortube(uint256 _amount) internal {
    uint256 b = balanceFortube();
    uint256 bT = balanceFortubeInToken();
    require(bT >= _amount, "insufficient funds");
    uint256 amount = (b.mul(_amount)).div(bT).add(1);
    _withdrawFortube(amount);
  }

  function _withdrawSome(uint256 _amount) internal {
    if (provider == Lender.AAVE) {
      require(balanceAave() >= _amount, "insufficient funds");
      _withdrawAave(_amount);
    }
    if (provider == Lender.FULCRUM) {
      _withdrawSomeFulcrum(_amount);
    }
    if (provider == Lender.FORTUBE) {
      _withdrawSomeFortube(_amount);
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
      } else if (newProvider == Lender.FORTUBE) {
        supplyFortube(balance());
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
      } else if (newProvider == Lender.FORTUBE) {
        supplyFortube(_balance());
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
  function supplyFortube(uint amount) public {
      require(amount > 0, "FORTUBE: supply failed");
      FortubeBank(fortubeBank).deposit(token, amount);
  }
  function _withdrawAave(uint amount) internal {
      Aave(getAave()).withdraw(token, amount, address(this));
  }
  function _withdrawFulcrum(uint amount) internal {
      require(Fulcrum(fulcrum).burn(address(this), amount) > 0, "FULCRUM: withdraw failed");
  }
  function _withdrawFortube(uint amount) internal {
      require(amount > 0, "FORTUBE: withdraw failed");
      FortubeBank(fortubeBank).withdraw(token, amount);
  }

  function _calcPoolValueInToken() internal view returns (uint) {
    return _balanceFulcrumInToken()
      .add(_balanceAave())
      .add(_balanceFortubeInToken())
      .add(_balance());
  }

  function calcPoolValueInToken() public view returns (uint) {

    return balanceFulcrumInToken()
      .add(balanceAave())
      .add(balanceFortubeInToken())
      .add(balance());
  }

  function getPricePerFullShare() public view returns (uint) {
    uint _pool = calcPoolValueInToken();
    return _pool.mul(1e18).div(_totalSupply);
  }
}