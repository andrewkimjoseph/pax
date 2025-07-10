// src/utils/signatures.ts
import {
  Address,
  Hex,
  verifyTypedData,
} from "viem";
import { celo } from "viem/chains";
import { createViemAccount } from "@privy-io/server-auth/viem";
import { randomBytes } from "crypto";
import { PRIVY_CLIENT } from "../config";

// Generate a random nonce for signatures
export function generateRandomNonce(): bigint {
  const randomBytes32 = randomBytes(32);  
  const randomHex = randomBytes32.toString('hex');
  return BigInt(`0x${randomHex}`);
}

// Define the types for screening requests
type ScreeningRequestTypes = {
  EIP712Domain: [
    { name: 'name'; type: 'string' },
    { name: 'version'; type: 'string' },
    { name: 'chainId'; type: 'uint256' },
    { name: 'verifyingContract'; type: 'address' }
  ];
  ScreeningRequest: [
    { name: 'participant'; type: 'address' },
    { name: 'taskId'; type: 'string' },
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
 * Sign a screening request using EIP-712 typed data
 * @param taskMasterServerWalletId The wallet ID of the task master
 * @param taskMasterServerWalletAddress The wallet address of the task master
 * @param taskManagerContractAddress TaskManager contract address
 * @param participantProxy Address of the participant proxy being screened
 * @param taskId Unique identifier for this task
 * @param nonce Random value to prevent replay attacks
 * @returns Promise containing the signature
 */
export async function signScreeningRequest(
  taskMasterServerWalletId: string,
  taskMasterServerWalletAddress: Address,
  taskManagerContractAddress: Address,
  participantProxy: Address,
  taskId: string,
  nonce: bigint
): Promise<Hex> {
  // Create viem account from Privy wallet
  const signerAccount = await createViemAccount({
    walletId: taskMasterServerWalletId,
    address: taskMasterServerWalletAddress,
    privy: PRIVY_CLIENT,
  });

  const types: ScreeningRequestTypes = {
    EIP712Domain: [
      { name: 'name', type: 'string' },
      { name: 'version', type: 'string' },
      { name: 'chainId', type: 'uint256' },
      { name: 'verifyingContract', type: 'address' }
    ],
    ScreeningRequest: [
      { name: 'participant', type: 'address' },
      { name: 'taskId', type: 'string' },
      { name: 'nonce', type: 'uint256' }
    ]
  };
  
  const domain = createDomain(taskManagerContractAddress);
  
  const message = {
    participant: participantProxy,
    taskId,
    nonce
  };

  return signerAccount.signTypedData({
    domain,
    types,
    primaryType: 'ScreeningRequest',
    message
  });
}

/**
 * Verify that a screening signature is valid and was signed by the expected signer
 * @param taskManagerContractAddress TaskManager contract address
 * @param participantProxy Address of the participant proxy being screened
 * @param taskId Unique identifier for this task
 * @param nonce Random value to prevent replay attacks
 * @param signature The signature to verify
 * @param expectedSigner The address that should have signed the message
 * @returns Promise resolving to true if the signature is valid, false otherwise
 */
export async function verifyScreeningSignature(
  taskManagerContractAddress: Address,
  participantProxy: Address,
  taskId: string,
  nonce: bigint,
  signature: Hex,
  expectedSigner: Address
): Promise<boolean> {
  try {
    const types: ScreeningRequestTypes = {
      EIP712Domain: [
        { name: 'name', type: 'string' },
        { name: 'version', type: 'string' },
        { name: 'chainId', type: 'uint256' },
        { name: 'verifyingContract', type: 'address' }
      ],
      ScreeningRequest: [
        { name: 'participant', type: 'address' },
        { name: 'taskId', type: 'string' },
        { name: 'nonce', type: 'uint256' }
      ]
    };
    
    const domain = createDomain(taskManagerContractAddress);
    
    const message = {
      participant: participantProxy,
      taskId,
      nonce
    };

    return await verifyTypedData({
      address: expectedSigner,
      domain,
      types,
      primaryType: 'ScreeningRequest',
      message,
      signature
    });
  } catch (error) {
    console.error("Signature verification error:", error);
    return false;
  }
}

/**
 * Create a complete screening signature package for a participant proxy
 * @param taskManagerContractAddress TaskManager contract address
 * @param taskMasterServerWalletId ID of the task master server wallet
 * @param taskMasterServerWalletAddress Address of the task master server wallet
 * @param participantProxy Address of the participant proxy to screen
 * @param taskId Task identifier
 * @param nonce Random nonce
 * @returns Object containing all necessary signature data
 */
export async function createScreeningSignaturePackage(
  taskManagerContractAddress: Address,
  taskMasterServerWalletId: string,
  taskMasterServerWalletAddress: Address,
  participantProxy: Address,
  taskId: string,
  nonce: bigint
) {
  const signature = await signScreeningRequest(
    taskMasterServerWalletId,
    taskMasterServerWalletAddress,
    taskManagerContractAddress,
    participantProxy,
    taskId,
    nonce
  );
  
  const isValid = await verifyScreeningSignature(
    taskManagerContractAddress,
    participantProxy,
    taskId,
    nonce,
    signature,
    taskMasterServerWalletAddress
  );
  
  return {
    signature,
    isValid,
    participantProxy,
    taskId,
    nonce: nonce.toString(),
  };
}