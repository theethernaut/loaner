import bre from "@nomiclabs/buidler"
import * as params from './params'
import * as utils from './utils/ethersutils'
import * as tokens from './tokens'
import * as flasher from "./flasher"

async function main() {
  const signer = bre.ethers.provider.getSigner(params.SIGNER)
  console.log(`\nSigner: ${params.SIGNER}`)

  const dai = tokens.getToken(params.DAI, signer)
  const usdc = tokens.getToken(params.USDC, signer)

  await flasher.deploy(signer)

  if (params.ALLOW_BAILOUTS) {
    await dai.approve(flasher.getAddress(), utils.toBigNum(100000000))
  }

  await flasher.execute(dai)

  await flasher.withdraw(dai)
  await flasher.withdraw(usdc)
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  })
