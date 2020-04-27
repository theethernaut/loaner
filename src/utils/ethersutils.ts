import { Signer } from 'ethers'
import { ContractReceipt, Contract } from 'ethers/contract'
import { formatUnits, parseUnits, BigNumber } from 'ethers/utils'
import { ethers } from '@nomiclabs/buidler'

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

export async function deployContract(contractName: string, params: any[] = []): Promise<Contract> {
  const factory = await ethers.getContractFactory(contractName)

  const contract = (await factory.deploy(...params)).deployed()

  return contract
}

export async function getContract(contractName: string, address: string): Promise<Contract> {
  const factory = await ethers.getContractFactory(contractName)
  const contract = factory.attach(address)

  return contract
}

export async function getFirstSigner(): Promise<Signer> {
  const signers = await ethers.getSigners()
  const signer = signers[0]

  await signer.getAddress()

  return signer
}
