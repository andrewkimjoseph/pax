// src/createPrivyServerWallet/index.ts
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions/v2";
import { createViemAccount } from "@privy-io/server-auth/viem";
import { entryPoint07Address } from "viem/account-abstraction";

import {
  FUNCTION_RUNTIME_OPTS,
  PRIVY_CLIENT,
  PUBLIC_CLIENT,
} from "../../shared/config";
import { Address } from "viem";

/**
 * Cloud function to create a Privy server wallet and Safe Smart Account
 */
export const createPrivyServerWallet = onCall(
  FUNCTION_RUNTIME_OPTS,
  async (request) => {
    try {
      const { toSimpleSmartAccount } = await import("permissionless/accounts");
      // Ensure the user is authenticated
      if (!request.auth) {
        logger.error("Unauthenticated request to createPrivyServerWallet", { requestAuth: request.auth });
        throw new HttpsError(
          "unauthenticated",
          "The function must be called by an authenticated user."
        );
      }

      const userId = request.auth.uid;

      // Log the operation start
      logger.info("Creating Privy server wallet", { userId });

      // Create a new wallet using Privy wallet API
      const wallet = await PRIVY_CLIENT.walletApi.createWallet({
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
        privy: PRIVY_CLIENT,
      });

      // Create Safe Smart Account
      const smartAccount = await toSimpleSmartAccount({
        client: PUBLIC_CLIENT,
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
  }
);
