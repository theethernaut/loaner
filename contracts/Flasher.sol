pragma solidity ^0.6.6;

import "./aave/FlashLoanReceiverBase.sol";
import "./aave/ILendingPoolAddressesProvider.sol";
import "./aave/ILendingPool.sol";

import "./maker/OasisExchanger.sol";
import "./maker/VaultManager.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract Flasher is FlashLoanReceiverBase, OasisExchanger, VaultManager {
    using SafeMath for uint256;

    IERC20 public constant dai =  IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 public constant usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    constructor(address _addressProvider) FlashLoanReceiverBase(_addressProvider) public {}

    event ExecuteCalled(address reserve, uint256 amount, uint256 balance, uint256 fee, bytes params);
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
        swapTokens(dai, _amount, usdc);

        // 2.
        uint256 usdcBalance = usdc.balanceOf(address(this));
        openVault(
            "USDC-A",
            usdcBalance,
            usdcBalance.div(2)
        );

        // 3.
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
