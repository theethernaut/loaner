import { Signer } from "ethers";
import * as params from '../params'
import * as utils from '../utils/ethersutils'
import { IERC20 } from "../../typechain/IERC20";
import { Flasher } from "../../typechain/Flasher";

const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

export async function deployContracts(signer: Signer, dai: IERC20): Promise<{flasher: Flasher}> {

  // Deploy the contract that will execute the flash loan.
  const flasher = await utils.deployContract('Flasher', [
    params.AAVE_PROVIDER
  ]) as Flasher

  // Give the flasher allowance over the signer's dai, in case
  // it needs money to pay the debt or the fees.
  if (params.ALLOW_BAILOUTS) {
    await dai.approve(flasher.address, utils.toBigNum(100000000))
  }

  return {
    flasher
  }
}