pragma solidity ^0.6.6;

import "./interfaces/IOasisExchange.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract OasisExchanger {
    IOasisExchange public constant oasisExchange = IOasisExchange(0x794e6e91555438aFc3ccF1c5076A74F42133d08D);

    event TokenSwap(
      uint256 sellTokenBalanceBefore,
      uint256 buyTokenBalanceBefore,
      uint256 sellTokenBalanceAfter,
      uint256 buyTokenBalanceAfter
    );

    function swapTokens(IERC20 _sellToken, uint256 _amountToSell, IERC20 _buyToken) public {
        uint256 sellTokenBalanceBefore = _sellToken.balanceOf(address(this));
        uint256 buyTokenBalanceBefore = _buyToken.balanceOf(address(this));
        require(sellTokenBalanceBefore >= _amountToSell, "Not enough sellToken to sell.");

        // Allow the exchange to move some of the contract's sellToken.
        _sellToken.approve(address(oasisExchange), uint256(-1));

        // Reject low quotes.
        // TODO.

        // Perform the exchange.
        oasisExchange.sellAllAmount(
            _sellToken,
            _amountToSell,
            _buyToken,
            1
        );

        // Register balances after swap.
        uint256 sellTokenBalanceAfter = _sellToken.balanceOf(address(this));
        uint256 buyTokenBalanceAfter = _buyToken.balanceOf(address(this));

        emit TokenSwap(sellTokenBalanceBefore, buyTokenBalanceBefore, sellTokenBalanceAfter, buyTokenBalanceAfter);
    }
}

