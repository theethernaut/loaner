pragma solidity ^0.6.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


abstract contract IOasisExchange {
    function getBuyAmount(IERC20 buyGem, IERC20 payGem, uint256 payAmt)
        virtual
        external
        view
        returns (uint256 fillAmt);

    function sellAllAmount(IERC20 payGem, uint256 payAmt, IERC20 buyGem, uint256 minFillAmount)
        virtual
        external
        returns (uint256 fillAmt);
}