import { config } from "dotenv";
import * as admin from "firebase-admin";
import path from "path";

import {
  type Address,
  createPublicClient,
  http,
  type Hex,
} from "viem";
import { entryPoint07Address } from "viem/account-abstraction";
import { celo, } from "viem/chains";
import { createPimlicoClient } from "permissionless/clients/pimlico";
import { createSmartAccountClient, type SmartAccountClient } from "permissionless";
import { toSimpleSmartAccount } from "permissionless/accounts";
import { PrivyClient } from "@privy-io/server-auth";
import { createViemAccount, } from "@privy-io/server-auth/viem";


config();

var serviceAccount = require("./env/thepaxapp-firebase-adminsdk-fbsvc-d9e8b1fdff.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
});

export const AUTH = admin.auth();

export const CREDENTIALS_PATH = path.resolve(
  __dirname,
  "./env/thepaxapp-71fbcf5792b2.json"
);

export const SPREADSHEET_ID = process.env.GSHEET_ID || null;

export const SHEET_NAME = "Disabled Participants";


const PIMLICO_API_KEY = process.env.PIMLICO_API_KEY;
const PRIVY_APP_ID = process.env.PRIVY_APP_ID;
const PRIVY_APP_SECRET = process.env.PRIVY_APP_SECRET;
const PRIVY_WALLET_AUTH_PRIVATE_KEY = process.env.PRIVY_WALLET_AUTH_PRIVATE_KEY;

if (!PIMLICO_API_KEY) throw new Error("Missing PIMLICO_API_KEY");
if (!PRIVY_APP_ID) throw new Error("Missing PRIVY_APP_ID");
if (!PRIVY_APP_SECRET) throw new Error("Missing PRIVY_APP_SECRET");
if (!PRIVY_WALLET_AUTH_PRIVATE_KEY)
  throw new Error("Missing PRIVY_WALLET_AUTH_PRIVATE_KEY");


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

// Helper function to create a smart account client from a Privy wallet ID
export async function createSmartAccountClientFromPrivyWalletId(
  walletId: string,
) {
  const wallet = await privy.walletApi.getWallet({ id: walletId });

  const serverWalletAccount = await createViemAccount({
    walletId: wallet.id,
    address: wallet.address as Address,
    privy: privy as any,
  });

  const safeSmartAccount = await toSimpleSmartAccount({
    client: publicClient,
    owner: serverWalletAccount,
    entryPoint: {
      address: entryPoint07Address,
      version: "0.7",
    },    
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
   serverWalletAccount: serverWalletAccount,
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


export const TASK_MANAGER_WALLET_ID = "uuyiv1thc052evc3n77lzyyu";
