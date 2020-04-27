import { ContractReceipt } from "ethers/contract"

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
      keys.map(key => console.log(`  ${key}:`, args[`${key}`]))
    }
  } else {
    console.error(`Event ${eventName} not found in receipt.`)
  }
}
