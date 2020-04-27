import bre from "@nomiclabs/buidler"
import * as params from './params'
import * as utils from './utils/ethersutils'
import { getTokens } from './elements/getTokens'
import { deployContracts } from "./elements/deployContracts"
import { traceEvent } from './utils/traceEvent'

async function main() {
  const signer = bre.ethers.provider.getSigner(params.SIGNER)

  const { dai, usdc } = await getTokens(signer)
  const { flasher } = await deployContracts(signer, dai)

  const tx = await flasher.flashloan(
    dai.address,
    utils.toBigNum(params.DAI_TO_BORROW)
  )
  const receipt = await tx.wait()

  traceEvent(receipt, 'ExecuteCalled')
  traceEvent(receipt, 'Bailout')
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
