import * as utils from './utils/ethersutils'

import { ERC20 } from '../typechain/ERC20'
import { ERC20Factory } from '../typechain/ERC20Factory'

import { Signer } from 'ethers'

export async function getToken(address: string, signer: Signer): Promise<ERC20> {
  return ERC20Factory.connect(
    address,
    signer
  ) as ERC20
}

export async function traceTokenBalance(address: string, token: ERC20): Promise<void> {
  const balance = await token.balanceOf(address)

  console.log(`${utils.toNum(balance)} ${await token.symbol()}`)
}

