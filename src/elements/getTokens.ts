import * as params from '../params'

import { IERC20 } from '../../typechain/IERC20'
import { IERC20Factory } from '../../typechain/IERC20Factory'

import { Contract, Signer } from 'ethers'

export async function getTokens(signer: Signer): Promise<{dai: IERC20, usdc: IERC20}> {
  return {
    dai: await getToken(params.DAI, signer),
    usdc: await getToken(params.USDC, signer)
  }
}

async function getToken(address: string, signer: Signer): Promise<IERC20> {
  return IERC20Factory.connect(
    address,
    signer
  ) as IERC20
}
