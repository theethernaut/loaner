# Loaner

Flash loan experiment using AAVE.

## Experiment

The experiment basically bootstraps a flash loan and executes it, interacting with Oasis and Maker along the way.

## Operation

The financial operation doesn't make much sense per-se. The point of the experiment is not making money, but having a basic understanding of what programming a flash loan feels like.

Anyhow, here's what it does:

1. Borows 1000 DAI from the AAVE flash pool.
2. Swaps 1000 DAI to ~1010 USDC using Oasis.
3. Opens a Maker vault depositing 1010 USDC as collateral.
4. Withdraws ~750 DAI from the vault.
5. Withdraws 250 DAI from the EOA account and pays back the flash loan + fees.
6. Contract ends up owning a 1010 USDC vault, which was purchased with 250 DAI.

_Note: Atm, the opened vault is actually locked, since it belongs to a contract that has no way to interact with it. However, it shouldn't be hard to transfer the vault ownership to the signer EOA._

## Usage

1. Clone
2. Install with `yarn`
3. Compile contracts with `yarn compile`
4. Start a local fork of mainnet using:
```
  ganache-cli \
  --fork https://mainnet.infura.io/v3/<your-infura-key> \
  --networkId 66 \
  --unlock 0x4d10ae710Bd8D1C31bd7465c8CBC3add6F279E81 \
  --gasLimit 8000000
```
5. Start the script with `yarn start`
