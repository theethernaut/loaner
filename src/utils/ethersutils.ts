import { Signer } from 'ethers'
import { ContractReceipt, Contract } from 'ethers/contract'
import { formatUnits, parseUnits, BigNumber } from 'ethers/utils'
import { ethers } from '@nomiclabs/buidler'

export function traceEvent(receipt: ContractReceipt, eventName: string): void {
  console.log(`${eventName} event:`)

  let event
  if (receipt.events && receipt.events.length > 0) {
    event = receipt.events.find(e => e.event === eventName)
  } else {
    console.error('No events found in receipt.')
  }

  if (event) {
    if (event.args) {
      const args: any = event.args
      const keys = Object.keys(args)
      keys.map(key => {
        if (isNaN(Number(key)) && key !== 'length') {
          let value = args[`${key}`]

          if (BigNumber.isBigNumber(value)) {
            console.log(`  ${key}:`, toNum(value), `(${value})`)
          } else {
            console.log(`  ${key}:`, value)
          }
        }
      })
    }
  } else {
    console.error(`Event ${eventName} not found in receipt.`)
  }
}

export function toNum(value: BigNumber, decimals: number = 18): number {
  return parseFloat(formatUnits(value, decimals))
}

export function toBigNum(value: number, decimals: number = 18): BigNumber {
  return parseUnits(`${value}`, decimals)
}

export function returnValueFromTxReceipt(receipt: ContractReceipt, eventName: String, argName: String): any {
  const event = receipt.events!.find(e => e.event === eventName) as any
  return event.args[`${argName}`]
}

export function stringifyJson(json: any): string {
  return JSON.stringify(json, null, 2)
}

export async function getFirstSigner(): Promise<Signer> {
  const signers = await ethers.getSigners()
  const signer = signers[0]

  await signer.getAddress()

  return signer
}
