import {
  Address,
  Hex,
  verifyTypedData,
} from "viem";
import { celo, celoAlfajores } from "viem/chains";
import { WalletInfo } from "./wallets";

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
  chainId: BigInt(celoAlfajores.id),
  verifyingContract: contractAddress
});

/**
 * Sign a screening request using EIP-712 typed data
 * @param taskManagerWallet The wallet of the TaskManager (owner)
 * @param contractAddress TaskManager contract address
 * @param participant Address of the participant being screened
 * @param taskId Unique identifier for this task
 * @param nonce Random value to prevent replay attacks
 * @returns Promise containing the signature
 */
export async function signScreeningRequest(
  taskManagerWallet: WalletInfo,
  contractAddress: Address,
  participant: Address,
  taskId: string,
  nonce: bigint
): Promise<Hex> {
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
  
  const domain = createDomain(contractAddress);
  
  const message = {
    participant,
    taskId,
    nonce
  };

  return taskManagerWallet.serverWalletAccount.signTypedData({
    domain,
    types,
    primaryType: 'ScreeningRequest',
    message
  });
}

/**
 * Sign a reward claim request using EIP-712 typed data
 * @param taskManagerWallet The wallet of the TaskManager (owner)
 * @param contractAddress TaskManager contract address
 * @param participant Address of the participant claiming the reward
 * @param rewardId Unique identifier for this reward claim
 * @param nonce Random value to prevent replay attacks
 * @returns Promise containing the signature
 */
export async function signRewardClaimRequest(
  taskManagerWallet: WalletInfo,
  contractAddress: Address,
  participant: Address,
  rewardId: string,
  nonce: bigint
): Promise<Hex> {
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
  
  const domain = createDomain(contractAddress);
  
  const message = {
    participant,
    rewardId,
    nonce
  };

  return taskManagerWallet.serverWalletAccount.signTypedData({
    domain,
    types,
    primaryType: 'RewardClaimRequest',
    message
  });
}

/**
 * Verify that a screening signature is valid and was signed by the expected signer
 * @param contractAddress TaskManager contract address
 * @param participant Address of the participant being screened
 * @param taskId Unique identifier for this task
 * @param nonce Random value to prevent replay attacks
 * @param signature The signature to verify
 * @param expectedSigner The address that should have signed the message
 * @returns Promise resolving to true if the signature is valid, false otherwise
 */
export async function verifyScreeningSignature(
  contractAddress: Address,
  participant: Address,
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
    
    const domain = createDomain(contractAddress);
    
    const message = {
      participant,
      taskId,
      nonce
    };

    // For simplicity in test environments
    // return true;

    // For production:
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
 * Verify that a reward claim signature is valid and was signed by the expected signer
 * @param contractAddress TaskManager contract address
 * @param participant Address of the participant claiming the reward
 * @param rewardId Unique identifier for this reward claim
 * @param nonce Random value to prevent replay attacks
 * @param signature The signature to verify
 * @param expectedSigner The address that should have signed the message
 * @returns Promise resolving to true if the signature is valid, false otherwise
 */
export async function verifyRewardClaimSignature(
  contractAddress: Address,
  participant: Address,
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
    
    const domain = createDomain(contractAddress);
    
    const message = {
      participant,
      rewardId,
      nonce
    };

    // // For simplicity in test environments
    // return true;

    // For production:
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
 * Create a complete screening signature package for a participant
 * @param taskManagerContract TaskManager contract address
 * @param taskManagerWallet TaskManager wallet info
 * @param participantAddress Participant address to screen
 * @param taskId Task identifier
 * @param nonce Random nonce
 * @returns Object containing all necessary signature data
 */
export async function createScreeningSignaturePackage(
  taskManagerContract: Address,
  taskManagerWallet: WalletInfo,
  participantAddress: Address,
  taskId: string,
  nonce: bigint
) {
  const signature = await signScreeningRequest(
    taskManagerWallet,
    taskManagerContract,
    participantAddress,
    taskId,
    nonce
  );

  const isValid = await verifyScreeningSignature(
    taskManagerContract,
    participantAddress,
    taskId,
    nonce,
    signature,
    taskManagerWallet.serverWalletAccount.address
  );

  return {
    signature,
    isValid,
    participantAddress,
    taskId,
    nonce,
  };
}

/**
 * Create a complete reward claim signature package for a participant
 * @param taskManagerContract TaskManager contract address
 * @param taskManagerWallet TaskManager wallet info
 * @param participantAddress Participant address claiming reward
 * @param rewardId Reward identifier
 * @param nonce Random nonce
 * @returns Object containing all necessary signature data
 */
export async function createRewardClaimSignaturePackage(
  taskManagerContract: Address,
  taskManagerWallet: WalletInfo,
  participantAddress: Address,
  rewardId: string,
  nonce: bigint
) {
  const signature = await signRewardClaimRequest(
    taskManagerWallet,
    taskManagerContract,
    participantAddress,
    rewardId,
    nonce
  );

  const isValid = await verifyRewardClaimSignature(
    taskManagerContract,
    participantAddress,
    rewardId,
    nonce,
    signature,
    taskManagerWallet.serverWalletAccount.address
  );

  return {
    signature,
    isValid,
    participantAddress,
    rewardId,
    nonce,
  };
}