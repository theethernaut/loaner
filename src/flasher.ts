import { Signer } from "ethers";
import * as params from './params'
import * as utils from './utils/ethersutils'
import { ERC20 } from "../typechain/ERC20";
import { FlasherFactory } from "../typechain/FlasherFactory";
import { Flasher } from "../typechain/Flasher";

let flasher: Flasher

export function getAddress(): string {
  return flasher.address
}

export async function deploy(signer: Signer): Promise<void> {
  console.log(`\nDeploying Flasher...`)

  // Deploy the contract that will execute the flash loan.
  const flasherFactory = new FlasherFactory(signer)
  flasher = await flasherFactory.deploy(
    params.AAVE_PROVIDER,
    params.overrides
  ) as Flasher

  console.log(`Flasher: ${flasher.address}`)
}

export async function execute(dai: ERC20): Promise<void> {
  console.log(`\nExecuting flash loan...`)

  const tx = await flasher.flashloan(
    dai.address,
    utils.toBigNum(params.DAI_TO_BORROW),
    params.overrides
  )
  const receipt = await tx.wait()

  utils.traceEvent(receipt, 'ExecuteCalled')
  utils.traceEvent(receipt, 'TokenSwap')
  utils.traceEvent(receipt, 'Bailout')
}

export async function withdraw(token: ERC20): Promise<void> {
  const symbol = await token.symbol()
  const decimals = await token.decimals()
  const balance = await token.balanceOf(flasher.address)

  console.log(`Withdrawing ${utils.toNum(balance, decimals)} ${symbol} from Flasher...`)

  const tx = await flasher.withdraw(token.address, params.overrides)
  await tx.wait()
}
