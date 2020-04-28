pragma solidity ^0.6.6;

import "./interfaces/IDssProxyActions.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract VaultManager {
  IDssProxyActions actions = IDssProxyActions(0x82ecD135Dce65Fbc6DbdD0e4237E0AF93FFD5038);

  address manager = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
  address jug = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
  address daiJoinAdapter = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;

  struct GemInfo {
    IERC20 token;
    address joinAdapter;
  }

  mapping(bytes32 => GemInfo) public gems;

  constructor() public {
    gems["USDC-A"] = GemInfo(
      IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48),
      0xA191e578a6736167326d05c119CE0c90849E84B7
    );
  }

  event VaultCreated(uint256 vaultId);

  event Log(bytes32 data);

  function openVault(
    bytes32 _collateralAlias,
    uint256 _collateralAmount,
    uint256 _daiLoanAmount
  ) public {
    GemInfo storage gem = gems[_collateralAlias];
    require(gem.joinAdapter != address(0x0), "Unsupported collateral type.");

    gem.token.approve(gem.joinAdapter, uint256(-1));

    uint256 vaultId = actions.openLockGemAndDraw(
      manager,
      jug,
      gem.joinAdapter,
      daiJoinAdapter,
      _collateralAlias,
      _collateralAmount,
      _daiLoanAmount,
      true
    );

    emit VaultCreated(vaultId);
  }
}