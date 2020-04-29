pragma solidity ^0.6.6;

import "./interfaces/ActionsLike.sol";


contract VaultManager {
    ActionsLike public constant actions = ActionsLike(0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038);

    address public constant manager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address public constant jug     = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address public constant daiJoin = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;

    event VaultCreated(uint256 vaultId);

    function getGemJoinAddress(bytes32 _gemAlias) public returns (address) {
        if (_gemAlias == 'USDC-A') return 0xA191e578a6736167326d05c119CE0c90849E84B7;

        revert('Unrecognized gem.');
    }

    function openVault(bytes32 _collateralGemAlias, uint256 _amountToLock, uint256 _amountToMint) public {
        address gemJoin = getGemJoinAddress(_collateralGemAlias);

        bytes memory data = abi.encodeWithSelector(
            actions.openLockGemAndDraw.selector,
            manager,
            jug,
            gemJoin,
            daiJoin,
            // 0x555344432d410000000000000000000000000000000000000000000000000000,
            _collateralGemAlias,
            _amountToLock,
            _amountToMint,
            true
        );

        (bool success, bytes memory returnData) = address(actions).delegatecall(data);
        require(success, 'Vault creation was not successful.');

        uint256 vaultId = abi.decode(returnData, (uint256));

        emit VaultCreated(vaultId);
    }
}
