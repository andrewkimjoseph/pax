import { Address, parseEther } from "viem";
import { create2Factory, waitForUserOperationReceipt } from "../utils/clients";
import { getTaskManagerDeployDataAndSalt, findContractAddressFromLogs, REWARD_TOKEN_ADDRESS } from "../utils/helpers";
import { WalletInfo } from "../utils/wallets";

/**
 * Deploy a TaskManager contract using a smart account
 * @param taskManagerWallet Wallet that will own and manage the TaskManager - Server Wallet
 * @param rewardAmount Amount of tokens to reward each participant
 * @param targetParticipants Maximum number of participants for the task
 * @param rewardTokenAddress Address of the ERC20 token used for rewards
 * @returns The deployed TaskManager contract address
 */
export async function deployTaskManager(
  taskManagerWallet: WalletInfo,
  rewardAmount: bigint = parseEther("0.01"),
  targetParticipants: bigint = 5n,
  rewardTokenAddress: Address = REWARD_TOKEN_ADDRESS
): Promise<Address> {
  console.log(`Deploying TaskManager for signer: ${taskManagerWallet.serverWalletAccount.address}`);
  console.log(`Owner (taskMaster): ${taskManagerWallet.safeSmartAccount.address}`);
  console.log(`Reward amount: ${rewardAmount} wei`);
  console.log(`Target participants: ${targetParticipants}`);
  console.log(`Reward token address: ${rewardTokenAddress}`);

  // Get deployment data with salt for CREATE2
  const { deployData } = getTaskManagerDeployDataAndSalt(
    taskManagerWallet.serverWalletAccount.address,
    taskManagerWallet.safeSmartAccount.address,
    rewardAmount,
    targetParticipants,
    rewardTokenAddress
  );

  const userOpHash = await taskManagerWallet.client.sendUserOperation({

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
    taskManagerWallet.client,
    userOpHash
  );

  const txHash = receipt.receipt.transactionHash;
  console.log("Transaction hash:", txHash);

  // Retrieve contract address from logs
  const contractAddress = await findContractAddressFromLogs(
    txHash,
    "TaskManagerCreated(address,address,address)"
  );

  if (!contractAddress) {
    throw new Error("Failed to retrieve TaskManager address from logs");
  }

  console.log(`TaskManager deployed at: ${contractAddress}`);
  return contractAddress;
}