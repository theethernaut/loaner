import * as assert from 'assert'
import * as params from '../src/params'
import * as utils from '../src/utils/ethersutils'
import bre from '@nomiclabs/buidler'
import { OasisExchanger } from '../typechain/OasisExchanger'
import { OasisExchangerFactory } from '../typechain/OasisExchangerFactory'
import { Signer } from 'ethers'
import * as tokens from '../src/tokens'
import { ERC20 } from '../typechain/ERC20'

describe('OasisExchanger', () => {
  let signer: Signer
  let dai: ERC20
  let usdc: ERC20
  let exchanger: OasisExchanger

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
    const factory = new OasisExchangerFactory(signer)
    exchanger = await factory.deploy(
      params.overrides
    ) as OasisExchanger

    console.log('OasisExchanger:', exchanger.address)
  })

  it('swaps dai for usdc', async () => {
    let exchangerUsdcBalance = await usdc.balanceOf(exchanger.address)
    console.log('Exchanger USDC balance (before):', utils.toNum(exchangerUsdcBalance))

    let tx

    const amountToSell = utils.toBigNum(1000)
    tx = await dai.transfer(exchanger.address, amountToSell)
    await tx.wait()

    tx = await exchanger.swapTokens(
      dai.address,
      amountToSell,
      usdc.address,
      params.overrides
    )
    await tx.wait()

    exchangerUsdcBalance = await usdc.balanceOf(exchanger.address)
    console.log('Exchanger USDC balance (after):', utils.toNum(exchangerUsdcBalance, 6))

    assert.ok(utils.toNum(exchangerUsdcBalance, 6) >= utils.toNum(amountToSell))
  })
})