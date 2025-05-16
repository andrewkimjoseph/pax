// src/createPrivyServerWallet/index.ts
import {
  onCall,
  HttpsError,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { PrivyClient } from "@privy-io/server-auth";
import { createViemAccount } from "@privy-io/server-auth/viem";
import { toSimpleSmartAccount } from "permissionless/accounts";
import { createPublicClient, http, Address } from "viem";
import { celo } from "viem/chains";
import { entryPoint07Address } from "viem/account-abstraction";

import {
  PRIVY_APP_ID,
  PRIVY_APP_SECRET,
  PRIVY_WALLET_AUTH_PRIVATE_KEY,
  FUNCTION_RUNTIME_OPTS
} from "../../shared/config";



// Initialize Privy client
const privy = new PrivyClient(PRIVY_APP_ID, PRIVY_APP_SECRET, {
  walletApi: {
    authorizationPrivateKey: PRIVY_WALLET_AUTH_PRIVATE_KEY,
  },
});

// Initialize public client
const publicClient = createPublicClient({
  chain: celo,
  transport: http(),
});

/**
 * Cloud function to create a Privy server wallet and Safe Smart Account
 */
export const createPrivyServerWallet = onCall(FUNCTION_RUNTIME_OPTS, async (request) => {
  try {
    // Ensure the user is authenticated
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called by an authenticated user."
      );
    }

    const userId = request.auth.uid;

    // Log the operation start
    logger.info("Creating Privy server wallet", { userId });

    // Create a new wallet using Privy wallet API
    const wallet = await privy.walletApi.createWallet({
      chainType: "ethereum",
    });

    logger.info("Created Privy wallet", {
      walletId: wallet.id,
      address: wallet.address,
    });

    // Create viem account from Privy wallet
    const serverWalletAccount = await createViemAccount({
      walletId: wallet.id,
      address: wallet.address as Address,
      privy,
    });

    // Create Safe Smart Account
    const smartAccount = await toSimpleSmartAccount({
      client: publicClient,
      owner: serverWalletAccount,
      entryPoint: {
        address: entryPoint07Address,
        version: "0.7",
      },
    });

    logger.info("Created Safe Smart Account", {
      safeAddress: smartAccount.address,
    });

    // Return wallet details
    return {
      serverWalletId: wallet.id,
      serverWalletAddress: wallet.address,
      smartAccountWalletAddress: smartAccount.address,
    };
  } catch (error) {
    logger.error("Error creating server wallet", { error });

    let errorMessage = "Unknown error occurred";
    if (error instanceof Error) {
      errorMessage = error.message;
    }

    throw new HttpsError(
      "internal",
      `Failed to create server wallet: ${errorMessage}`
    );
  }
});
