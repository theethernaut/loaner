pragma solidity ^0.6.6;

import "./interfaces/ActionsLike.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract VaultManager {
    ActionsLike public constant actions = ActionsLike(0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038);

    address public constant manager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public constant jug     = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public constant daiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;

    event VaultCreated(uint256 vaultId, uint256 amountLocked, uint256 amountMinted);

    function getGemJoinAddress(bytes32 _gemAlias) public pure returns (address) {
        if (_gemAlias == 'USDC-A') return 0xA191e578a6736167326d05c119CE0c90849E84B7;

        revert('Unrecognized gem.');
    }

    /*
       Opens a vault and mints dai to msg.sender.
    */
    function openVault(
        IERC20 _collateralToken,
        bytes32 _collateralGemAlias,
        uint256 _amountToLock,
        uint256 _amountToMint,
        bool transferTokens
    ) public {
        address gemJoin = getGemJoinAddress(_collateralGemAlias);

        if (!transferTokens) {
            uint256 allowance = _collateralToken.allowance(address(this), gemJoin);
            if (allowance != uint256(-1)) {
              _collateralToken.approve(gemJoin, uint256(-1));
            }
        }

        bytes memory data = abi.encodeWithSelector(
            actions.openLockGemAndDraw.selector,
            manager,
            jug,
            gemJoin,
            daiJoin,
            _collateralGemAlias,
            _amountToLock,
            _amountToMint,
            transferTokens
        );

        (bool success, bytes memory returnData) = address(actions).delegatecall(data);
        require(success, 'Error while attempting to create vault.');

        uint256 vaultId = abi.decode(returnData, (uint256));

        emit VaultCreated(vaultId, _amountToLock, _amountToMint);
    }

    /*
       Opens a vault and mints dai to address(this).
    */
    function openVaultForThis(
        IERC20 _collateralToken,
        bytes32 _collateralGemAlias,
        uint256 _amountToLock,
        uint256 _amountToMint,
        bool transferTokens
    ) public {
        this.openVault(
            _collateralToken,
            _collateralGemAlias,
            _amountToLock,
            _amountToMint,
            transferTokens
        );
    }
}
