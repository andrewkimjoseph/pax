import { encodeFunctionData, parseUnits, type Address } from "viem";
import { createSmartAccountClientFromPrivyWalletId, TASK_MANAGER_WALLET_ID } from "../../config";
import { taskManagerV2ABI } from "../../utils/abis/taskManagerV2";
import { erc20ABI } from "../../utils/abis/erc20";

const sendTokensToAddress = async (tokenAddress: string, recipient: string) => {
  const smartAccountClient = await createSmartAccountClientFromPrivyWalletId(
    TASK_MANAGER_WALLET_ID
  );


  const transferData = encodeFunctionData({
    abi: erc20ABI,
    functionName: "transfer",
    args: [recipient, parseUnits("37.5", 6)],
  });

  // Send user operation to call withdrawToPaymentMethod
  const userOpTxnHash = await smartAccountClient.smartAccountClient.sendUserOperation({
    calls: [
      {
        to: tokenAddress as Address,
        value: BigInt(0),
        data: (transferData) as Address,
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

  const bundleTxnHash = userOpReceipt.receipt.transactionHash;
  console.log("Bundle transaction confirmed", { bundleTxnHash });

};


const run = async () => {
  const recipient = "0x9cfa5C4BFE08A1A3F7c17D6503EeB23A0290c4Ca";
  const tokenAddress = "0x48065fbBE25f71C9282ddf5e1cD6D6A887483D5e";
  await sendTokensToAddress(tokenAddress, recipient);
};  

run();