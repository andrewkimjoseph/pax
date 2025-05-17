import { Account, Address, LocalAccount } from "viem";
import {
  createSmartAccountClientFromPrivyWalletId,
} from "./clients";
import { SmartAccountClient } from "permissionless";
import { ToSafeSmartAccountReturnType } from "permissionless/accounts";

// Privy wallet IDs as specified in the requirements
export const WALLET_IDS = {
  TASK_MANAGER: "kktwo7fkm8w5rgyjvjl1gxo3",
  PARTICIPANT_2: "gbg7lsei9hxebof223plfazr",
  PARTICIPANT_3: "kid3rhgmxtj0abjdv8qy741z",
  PARTICIPANT_4: "vy1qys3y4hvypn8z1zo1n0r3",
};

// Interface for wallet information
export interface WalletInfo {
  walletId: string;
  address: Address;
  client: SmartAccountClient;
  safeSmartAccount: ToSafeSmartAccountReturnType;
  serverWalletAccount: LocalAccount;
}

// Global wallet cache to avoid recreating clients
const walletCache = new Map<string, WalletInfo>();

/**
 * Get wallet information and smart account client for a specific wallet ID
 * @param walletId Privy wallet ID
 * @returns Wallet information including address and smart account client
 */
export async function getWalletInfo(
  walletId: string,
  isTaskMaster: boolean = false,
): Promise<WalletInfo> {
  // Return from cache if available
  if (walletCache.has(walletId)) {
    return walletCache.get(walletId) as WalletInfo;
  }

  // Create new smart account client

  let walletInfo: WalletInfo;


    const {
      smartAccountClient,
      smartAccountAddress,
      safeSmartAccount,
      serverWalletAccount,
    } = await createSmartAccountClientFromPrivyWalletId(walletId);
    walletInfo = {
      walletId,
      address: smartAccountAddress,
      client: smartAccountClient,
      safeSmartAccount,
      serverWalletAccount: serverWalletAccount,
    };
  
  // Store in cache
  walletCache.set(walletId, walletInfo);

  return walletInfo;
}

/**
 * Get all wallet information for all participants
 * @returns Array of wallet information
 */
export async function getAllWallets(): Promise<WalletInfo[]> {
  const walletIds = Object.values(WALLET_IDS);
  const walletPromises = walletIds.map((walletId) => getWalletInfo(walletId));
  return Promise.all(walletPromises);
}

/**
 * Clear wallet cache (useful for testing)
 */
export function clearWalletCache(): void {
  walletCache.clear();
}
