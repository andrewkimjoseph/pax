import { Address, Hex } from "viem";
import { create2Factory, publicClient, waitForUserOperationReceipt } from "../utils/clients";
import { getProxyDeployDataAndSalt, findContractAddressFromLogs, IMPLEMENTATION_ADDRESS } from "../utils/helpers";
import { WalletInfo } from "../utils/wallets";

/**
 * Deploy a PaxAccount proxy contract using a smart account
 * @param ownerWallet Wallet that will own the PaxAccount
 * @param primaryPaymentMethod Address to set as the primary payment method
 * @returns The deployed PaxAccount proxy address
 */
export async function deployPaxAccountProxy(
  ownerWallet: WalletInfo,
  primaryPaymentMethod: Address
): Promise<Address> {
  console.log(`Deploying PaxAccount proxy for owner: ${ownerWallet.address}`);
  console.log(`Implementation address: ${IMPLEMENTATION_ADDRESS}`);
  console.log(`Primary payment method: ${primaryPaymentMethod}`);

  // Get deployment data with salt for CREATE2
  const { deployData } = getProxyDeployDataAndSalt(
    ownerWallet.address,
    primaryPaymentMethod
  );

  // Deploy using CREATE2 factory via account abstraction
  const userOpHash = await ownerWallet.client.sendUserOperation({
    calls: [
      {
        to: create2Factory,
        value: 0n,
        data: deployData,
      },
    ],
  });

  console.log("User operation hash:", userOpHash);

  // Wait for user operation receipt
  const receipt = await waitForUserOperationReceipt(
    ownerWallet.client,
    userOpHash
  );

  const txHash = receipt.receipt.transactionHash;
  console.log("Transaction hash:", txHash);

  // Retrieve proxy address from logs
  const proxyAddress = await findContractAddressFromLogs(
    txHash,
    "PaxAccountCreated(address)"
  );

  if (!proxyAddress) {
    throw new Error("Failed to retrieve PaxAccount proxy address from logs");
  }

  console.log(`PaxAccount proxy deployed at: ${proxyAddress}`);
  return proxyAddress;
}