import * as assert from 'assert'
import * as params from '../src/params'
import * as utils from '../src/utils/ethersutils'
import bre from '@nomiclabs/buidler'
import { VaultManager } from '../typechain/VaultManager'
import { VaultManagerFactory } from '../typechain/VaultManagerFactory'
import { Signer } from 'ethers'
import * as tokens from '../src/tokens'
import { ERC20 } from '../typechain/ERC20'

describe.only('VaultManager', () => {
  let signer: Signer
  let dai: ERC20
  let usdc: ERC20
  let manager: VaultManager

  before('retrieve signer', async () => {
    signer = bre.ethers.provider.getSigner(params.SIGNER)
    console.log(`Signer: ${params.SIGNER}`)
  })

  before('retrieve tokens', async () => {
    dai = tokens.getToken(params.DAI, signer)
    usdc = tokens.getToken(params.USDC, signer)
    console.log('DAI:', dai.address)
    console.log('USDC:', usdc.address)
  })

  before('deploy contract', async () => {
    const factory = new VaultManagerFactory(signer)
    manager = await factory.deploy(
      params.overrides
    ) as VaultManager

    console.log('VaultManager:', manager.address)
  })

  it('opens a vault', async () => {
    let tx, receipt

    const daiBalanceBefore = await dai.balanceOf(params.SIGNER)
    const usdcBalanceBefore = await usdc.balanceOf(params.SIGNER)
    console.log(`Dai balance (before): ${utils.toNum(daiBalanceBefore)}`)
    console.log(`Usdc balance (before): ${utils.toNum(usdcBalanceBefore, 6)}`)

    const amountToLock = utils.toBigNum(1000, 6)
    tx = await usdc.approve(manager.address, amountToLock)
    await tx.wait()

    const amountToMint = utils.toBigNum(500)

    tx = await manager.openVault(
      usdc.address,
      bre.ethers.utils.formatBytes32String('USDC-A'),
      amountToLock,
      amountToMint,
      true,
      params.overrides
    )
    receipt = await tx.wait()

    utils.traceEvent(receipt, 'VaultCreated')
    const vaultId = utils.returnValueFromTxReceipt(receipt, 'VaultCreated', 'vaultId')
    assert.ok(utils.toNum(vaultId) > 0)

    const daiBalanceAfter = await dai.balanceOf(params.SIGNER)
    const usdcBalanceAfter = await usdc.balanceOf(params.SIGNER)
    console.log(`Usdc balance (after): ${utils.toNum(usdcBalanceAfter, 6)}`)
    console.log(`Dai balance (after): ${utils.toNum(daiBalanceAfter)}`)

    const deltaDaiBalance = daiBalanceAfter.sub(daiBalanceBefore)
    const deltaUsdcBalance = usdcBalanceAfter.sub(usdcBalanceBefore)
    console.log(`Usdc balance (delta): ${utils.toNum(deltaUsdcBalance, 6)}`)
    console.log(`Dai balance (delta): ${utils.toNum(deltaDaiBalance)}`)

    assert.ok(-utils.toNum(deltaUsdcBalance) == utils.toNum(amountToLock))
    assert.ok(utils.toNum(deltaDaiBalance) == utils.toNum(amountToMint))
  })
})
