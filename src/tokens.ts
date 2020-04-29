import * as utils from './utils/ethersutils'

import { ERC20 } from '../typechain/ERC20'
import { ERC20Factory } from '../typechain/ERC20Factory'

import { Signer } from 'ethers'

export function getToken(address: string, signer: Signer): ERC20 {
  return ERC20Factory.connect(
    address,
    signer
  ) as ERC20
}

export async function traceTokenBalance(address: string, token: ERC20): Promise<void> {
  const symbol = await token.symbol()
  const decimals = await token.decimals()
  const balance = await token.balanceOf(address)

  console.log(`${utils.toNum(balance, decimals)} ${symbol}`)
}

