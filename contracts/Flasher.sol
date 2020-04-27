pragma solidity ^0.6.6;

import "./aave/FlashLoanReceiverBase.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/ILendingPool.sol";

import "./oasis/IOasisExchange.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract Flasher is FlashLoanReceiverBase {
    using SafeMath for uint256;

    IERC20 public constant dai =  IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    IOasisExchange public constant oasisExchange = IOasisExchange(0x794e6e91555438aFc3ccF1c5076A74F42133d08D);

    constructor(address _addressProvider) FlashLoanReceiverBase(_addressProvider) public {}

    event ExecuteCalled(address reserve, uint256 amount, uint256 balance, uint256 fee, bytes params);
    event DaiUsdcSwap(uint256 daiBalanceBefore, uint256 usdcBalanceBefore, uint256 daiBalanceAfter, uint256 usdcBalanceAfter);
    event Bailout(uint256 bail);

    function executeOperation(
        address _reserve,       // Address of the token that was lended. Use ETH constant if ETH.
        uint256 _amount,        // Amount of _reserve token lent.
        uint256 _fee,           // Amount of _reserve token that will be charged as fee.
        bytes calldata _params  // Use this if dynamic params where sent.
    ) external override {
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance, was the flashLoan successful?");

        // Register incoming values from AAVE.
        uint256 registeredBalance = getBalanceInternal(address(this), _reserve);
        emit ExecuteCalled(_reserve, _amount, registeredBalance, _fee, _params);

        // Reject high fees.
        // TODO.

        // ------------------------------------------------------

        // 1. Exchange all loaned DAI to USDC.
        daiToUsdc(_amount);

        // 2.
        // TODO.

        // ------------------------------------------------------

        // Calculate amount to give back.
        uint totalDebt = _amount.add(_fee);

        // Need a bailout?
        uint256 daiBalance = dai.balanceOf(address(this));
        if (daiBalance < totalDebt) {
            uint256 bail = totalDebt.sub(daiBalance);
            dai.transferFrom(owner(), address(this), bail);

            emit Bailout(bail);
        }

        // Return loan.
        transferFundsBackToPoolInternal(_reserve, totalDebt);
    }

    function daiToUsdc(uint256 _amountToSell) public {
        // Register balances before swap.
        uint256 daiBalanceBefore = dai.balanceOf(address(this));
        uint256 usdcBalanceBefore = usdc.balanceOf(address(this));
        require(daiBalanceBefore >= _amountToSell, "Not enough dai to sell.");

        // Allow the exchange to move some of the contract's dai.
        dai.approve(address(oasisExchange), uint256(-1));

        // Reject low quotes.
        // TODO.

        // Perform the exchange.
        oasisExchange.sellAllAmount(
            dai,
            _amountToSell,
            usdc,
            1
        );

        // Register balances after swap.
        uint256 daiBalanceAfter = dai.balanceOf(address(this));
        uint256 usdcBalanceAfter = usdc.balanceOf(address(this));

        emit DaiUsdcSwap(daiBalanceBefore, usdcBalanceBefore, daiBalanceAfter, usdcBalanceAfter);
    }

    function flashloan(
        address _asset, // Address of the asset that will be lent.
        uint256 _amount // Amount that will be lent.
    ) public onlyOwner {
        bytes memory data = "";

        ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
        lendingPool.flashLoan(
            address(this), // Address of the contract that will receive the loan.
            _asset,        // Address of the asset that will be lent.
            _amount,       // Amount of the asset that will be lent.
            data           // Additional dynamic data.
        );
    }
}
