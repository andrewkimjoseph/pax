// src/utils/rewardSignatures.ts
import {
  Address,
  Hex,
  verifyTypedData,
} from "viem";
import { celo } from "viem/chains";
import { createViemAccount } from "@privy-io/server-auth/viem";
import { randomBytes } from "crypto";
import { PRIVY_CLIENT } from "../../shared/config";

// Generate a random nonce for signatures
export function generateRandomNonce(): bigint {
  // Use crypto.randomBytes to generate cryptographically strong random values
  const randomBytes32 = randomBytes(32);
  
  // Convert to hexadecimal string and then to BigInt
  const randomHex = randomBytes32.toString('hex');
  return BigInt(`0x${randomHex}`);
}

// Define the types for reward claim requests
type RewardClaimRequestTypes = {
  EIP712Domain: [
    { name: 'name'; type: 'string' },
    { name: 'version'; type: 'string' },
    { name: 'chainId'; type: 'uint256' },
    { name: 'verifyingContract'; type: 'address' }
  ];
  RewardClaimRequest: [
    { name: 'participant'; type: 'address' },
    { name: 'rewardId'; type: 'string' },
    { name: 'nonce'; type: 'uint256' }
  ];
};

// Define a concrete domain type with required fields
type TaskManagerDomain = {
  name: string;
  version: string;
  chainId: bigint;
  verifyingContract: Address;
};

// Create a domain object for EIP-712 signatures
const createDomain = (contractAddress: Address): TaskManagerDomain => ({
  name: 'TaskManager',
  version: '1',
  chainId: BigInt(celo.id),
  verifyingContract: contractAddress
});

/**
 * Sign a reward claim request using EIP-712 typed data
 * @param taskMasterServerWalletId The wallet ID of the task master
 * @param taskMasterServerWalletAddress The wallet address of the task master
 * @param taskManagerContractAddress TaskManager contract address
 * @param participantProxy Address of the participant proxy claiming the reward
 * @param rewardId Unique identifier for this reward
 * @param nonce Random value to prevent replay attacks
 * @returns Promise containing the signature
 */
export async function signRewardClaimRequest(
  taskMasterServerWalletId: string,
  taskMasterServerWalletAddress: Address,
  taskManagerContractAddress: Address,
  participantProxy: Address,
  rewardId: string,
  nonce: bigint
): Promise<Hex> {
  // Create viem account from Privy wallet
  const signerAccount = await createViemAccount({
    walletId: taskMasterServerWalletId,
    address: taskMasterServerWalletAddress,
    privy: PRIVY_CLIENT,
  });

  const types: RewardClaimRequestTypes = {
    EIP712Domain: [
      { name: 'name', type: 'string' },
      { name: 'version', type: 'string' },
      { name: 'chainId', type: 'uint256' },
      { name: 'verifyingContract', type: 'address' }
    ],
    RewardClaimRequest: [
      { name: 'participant', type: 'address' },
      { name: 'rewardId', type: 'string' },
      { name: 'nonce', type: 'uint256' }
    ]
  };
  
  const domain = createDomain(taskManagerContractAddress);
  
  const message = {
    participant: participantProxy,
    rewardId,
    nonce
  };

  return signerAccount.signTypedData({
    domain,
    types,
    primaryType: 'RewardClaimRequest',
    message
  });
}

/**
 * Verify that a reward claim signature is valid and was signed by the expected signer
 * @param taskManagerContractAddress TaskManager contract address
 * @param participantProxy Address of the participant proxy claiming the reward
 * @param rewardId Unique identifier for this reward
 * @param nonce Random value to prevent replay attacks
 * @param signature The signature to verify
 * @param expectedSigner The address that should have signed the message
 * @returns Promise resolving to true if the signature is valid, false otherwise
 */
export async function verifyRewardClaimSignature(
  taskManagerContractAddress: Address,
  participantProxy: Address,
  rewardId: string,
  nonce: bigint,
  signature: Hex,
  expectedSigner: Address
): Promise<boolean> {
  try {
    const types: RewardClaimRequestTypes = {
      EIP712Domain: [
        { name: 'name', type: 'string' },
        { name: 'version', type: 'string' },
        { name: 'chainId', type: 'uint256' },
        { name: 'verifyingContract', type: 'address' }
      ],
      RewardClaimRequest: [
        { name: 'participant', type: 'address' },
        { name: 'rewardId', type: 'string' },
        { name: 'nonce', type: 'uint256' }
      ]
    };
    
    const domain = createDomain(taskManagerContractAddress);
    
    const message = {
      participant: participantProxy,
      rewardId,
      nonce
    };

    return await verifyTypedData({
      address: expectedSigner,
      domain,
      types,
      primaryType: 'RewardClaimRequest',
      message,
      signature
    });
  } catch (error) {
    console.error("Signature verification error:", error);
    return false;
  }
}

/**
 * Create a complete reward claim signature package for a participant proxy
 * @param taskManagerContractAddress TaskManager contract address
 * @param taskMasterServerWalletId ID of the task master server wallet
 * @param taskMasterServerWalletAddress Address of the task master server wallet
 * @param participantProxy Address of the participant proxy claiming the reward
 * @param rewardId Reward identifier
 * @param nonce Random nonce
 * @returns Object containing all necessary signature data
 */
export async function createRewardClaimSignaturePackage(
  taskManagerContractAddress: Address,
  taskMasterServerWalletId: string,
  taskMasterServerWalletAddress: Address,
  participantProxy: Address,
  rewardId: string,
  nonce: bigint
) {
  const signature = await signRewardClaimRequest(
    taskMasterServerWalletId,
    taskMasterServerWalletAddress,
    taskManagerContractAddress,
    participantProxy,
    rewardId,
    nonce
  );
  
  const isValid = await verifyRewardClaimSignature(
    taskManagerContractAddress,
    participantProxy,
    rewardId,
    nonce,
    signature,
    taskMasterServerWalletAddress
  );
  
  return {
    signature,
    isValid,
    participantProxy,
    rewardId,
    nonce: nonce.toString(),
  };
}