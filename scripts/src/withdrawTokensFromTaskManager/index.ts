import { encodeFunctionData, type Address } from "viem";
import { createSmartAccountClientFromPrivyWalletId, TASK_MANAGER_WALLET_ID } from "../../config";
import { taskManagerV2ABI } from "../../utils/abis/taskManagerV2";

const withdrawTokensFromTaskManager = async () => {
  const smartAccountClient = await createSmartAccountClientFromPrivyWalletId(
    TASK_MANAGER_WALLET_ID
  );

  const taskManagerAddress = "0xB555869079033a91BB20d55074F819D306d6Ee66";

  const withdrawData = encodeFunctionData({
    abi: taskManagerV2ABI,
    functionName: "withdrawAllRewardTokenToTaskMaster",
  });

  // Send user operation to call withdrawToPaymentMethod
  const userOpTxnHash = await smartAccountClient.smartAccountClient.sendUserOperation({
    calls: [
      {
        to: taskManagerAddress as Address,
        value: BigInt(0),
        data: (withdrawData) as Address,
      },
    ],
  });

  console.log("User operation submitted", { userOpTxnHash });

  // Wait for user operation receipt
  const userOpReceipt =
    await smartAccountClient.smartAccountClient.waitForUserOperationReceipt({
      hash: userOpTxnHash,
    });

  if (!userOpReceipt.success) {
    console.error("User operation failed in withdrawToPaymentMethod", {
      userOpReceipt,
    });
    throw new Error("User operation failed");
  }

  // const txnHash = userOpReceipt.userOpHash;
  // logger.info("Transaction confirmed", { txnHash });

  const bundleTxnHash = userOpReceipt.receipt.transactionHash;
  console.log("Bundle transaction confirmed", { bundleTxnHash });

};


const run = async () => {
  await withdrawTokensFromTaskManager();
};  

run();