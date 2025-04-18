import {
  Address,
  createPublicClient,
  http,
  createWalletClient,
  Hex,
} from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo } from "viem/chains";
import { createPimlicoClient } from "permissionless/clients/pimlico";
import { createSmartAccountClient, SmartAccountClient } from "permissionless";
import { toSafeSmartAccount } from "permissionless/accounts";
import { PrivyClient } from "@privy-io/server-auth";
import { createViemAccount } from "@privy-io/server-auth/viem";
import { config } from "dotenv";
import { privateKeyToAccount } from "viem/accounts";

config();

const PIMLICO_API_KEY = process.env.PIMLICO_API_KEY;
const PRIVY_APP_ID = process.env.PRIVY_APP_ID;
const PRIVY_APP_SECRET = process.env.PRIVY_APP_SECRET;
const PRIVY_WALLET_AUTH_PRIVATE_KEY = process.env.PRIVY_WALLET_AUTH_PRIVATE_KEY;
// const INFURA_API_KEY = process.env.INFURA_API_KEY;
// const INFURA_RPC_URL = `https://celo-alfajores.infura.io/v3/${INFURA_API_KEY}`;

if (!PIMLICO_API_KEY) throw new Error("Missing PIMLICO_API_KEY");
if (!PRIVY_APP_ID) throw new Error("Missing PRIVY_APP_ID");
if (!PRIVY_APP_SECRET) throw new Error("Missing PRIVY_APP_SECRET");
if (!PRIVY_WALLET_AUTH_PRIVATE_KEY)
  throw new Error("Missing PRIVY_WALLET_AUTH_PRIVATE_KEY");
// if (!INFURA_API_KEY) throw new Error("Missing INFURA_API_KEY");

const PK = `0x${process.env.PK}` as Address;
// Initialize clients

export const masterOwner = privateKeyToAccount(PK);

export const publicClient = createPublicClient({
  chain: celo,
  transport: http(),
});

const pimlicoUrl = `https://api.pimlico.io/v2/42220/rpc?apikey=${PIMLICO_API_KEY}`;

export const pimlicoClient = createPimlicoClient({
  transport: http(pimlicoUrl),
  entryPoint: {
    address: entryPoint07Address,
    version: "0.7",
  },
});

export const privy = new PrivyClient(PRIVY_APP_ID, PRIVY_APP_SECRET, {
  walletApi: {
    authorizationPrivateKey: PRIVY_WALLET_AUTH_PRIVATE_KEY,
  },
});

// CREATE2 Factory address - standard factory on most EVM chains
export const create2Factory: Address =
  "0x4e59b44847b379578588920cA78FbF26c0B4956C";

// Helper function to create a smart account client from a Privy wallet ID
export async function createSmartAccountClientFromPrivyWalletId(
  walletId: string
) {
  const wallet = await privy.walletApi.getWallet({ id: walletId });

  const serverWalletAccount = await createViemAccount({
    walletId: wallet.id,
    address: wallet.address as Address,
    privy,
  });

  const safeSmartAccount = await toSafeSmartAccount({
    client: publicClient,
    owners: [serverWalletAccount],
    entryPoint: {
      address: entryPoint07Address,
      version: "0.7",
    },
    version: "1.4.1",
  });

  const smartAccountClient = createSmartAccountClient({
    account: safeSmartAccount,
    chain: celo,
    bundlerTransport: http(pimlicoUrl),
    paymaster: pimlicoClient,
    userOperation: {
      estimateFeesPerGas: async () => {
        return (await pimlicoClient.getUserOperationGasPrice()).fast;
      },
    },
  });

  return {
    serverWalletAccount,
    smartAccountClient,
    smartAccountAddress: safeSmartAccount.address,
    safeSmartAccount,
  };
}

export async function createSmartAccountForTaskMaster() {


  const safeSmartAccount = await toSafeSmartAccount({
    client: publicClient,
    owners: [masterOwner],
    entryPoint: {
      address: entryPoint07Address,
      version: "0.7",
    },
    version: "1.4.1",
    threshold: BigInt(1),
  });

  const smartAccountClient = createSmartAccountClient({
    account: safeSmartAccount,
    chain: celo,
    bundlerTransport: http(pimlicoUrl),
    paymaster: pimlicoClient,
    userOperation: {
      estimateFeesPerGas: async () => {
        return (await pimlicoClient.getUserOperationGasPrice()).fast;
      },
    },
  });

  return {
    localAccount:masterOwner,
    smartAccountClient,
    smartAccountAddress: safeSmartAccount.address,
    safeSmartAccount,
  };
}

// Helper to wait for user operation receipt and transaction confirmation
export async function waitForUserOperationReceipt(
  smartAccountClient: SmartAccountClient,
  userOpHash: Hex
) {
  const receipt = await smartAccountClient.waitForUserOperationReceipt({
    hash: userOpHash,
  });

  await publicClient.waitForTransactionReceipt({
    hash: receipt.receipt.transactionHash,
  });

  return receipt;
}
