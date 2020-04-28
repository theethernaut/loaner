pragma solidity ^0.6.6;

abstract contract IDssProxyActions {
    function openLockGemAndDraw(
        address manager,
        address jug,
        address gemJoin,
        address daiJoin,
        bytes32 ilk,
        uint wadC,
        uint wadD,
        bool transferFrom
    ) public virtual returns (uint cdp);
}
