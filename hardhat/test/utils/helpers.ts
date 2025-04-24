import { 
    Address, 
    Hex, 
    concat, 
    encodeAbiParameters, 
    encodeDeployData, 
    encodeFunctionData,
    keccak256,
    toHex,
    BlockTag 
  } from "viem";
  import { paxAccountV1ABI } from "../abis/paxAccountV1";
  import { taskManagerV1ABI } from "../abis/taskManagerV1";
  import { erc1967ProxyABI } from "../abis/erc1967Proxy";
  import { erc1967ByteCode } from "../bytecode/ERC1967";
  import { paxAccountV1Bytecode } from "../bytecode/paxAccountV1";
  import { taskManagerV1Bytecode } from "../bytecode/taskManagerV1";
  import { publicClient } from "./clients";
  import { randomBytes } from "crypto";
  import * as fs from 'fs';
  import * as path from 'path';
  
  
  // Constants
  export const IMPLEMENTATION_ADDRESS = "0xD9Ae701950bB2615b9a068C6a310156af6AD92A2" as Address;
  export const REWARD_TOKEN_ADDRESS = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1" as Address; // cUSD Alfajores
  // export const REWARD_TOKEN_ADDRESS = "0x765de816845861e75a25fca122bb6898b8b1282a" as Address; // cUSD Mainnet

  // Helper to calculate event signatures
  export function calculateEventSignature(eventSignatureString: string): string {
    const encoder = new TextEncoder();
    const bytes = encoder.encode(eventSignatureString);
    const hash = keccak256(bytes);
    return hash.toLowerCase();
  }
  
  // Get proxy deployment data with salt
  export function getProxyDeployDataAndSalt(
    ownerAddress: Address,
    primaryPaymentMethod: Address
  ): { deployData: Hex; salt: Hex } {
    // Generate a random salt for CREATE2
    const salt = toHex(randomBytes(32), { size: 32 });
  
    const initData = encodeFunctionData({
      abi: paxAccountV1ABI,
      functionName: "initialize",
      args: [ownerAddress, primaryPaymentMethod],
    });
  
    const proxyData = encodeDeployData({
      abi: erc1967ProxyABI,
      bytecode: erc1967ByteCode,
      args: [IMPLEMENTATION_ADDRESS, initData],
    });
  
    // Combine the salt with the deployment data
    const deployData = concat([salt, proxyData]);
  
    return { deployData, salt };
  }
  
  // Get TaskManager deployment data with salt
  export function getTaskManagerDeployDataAndSalt(
    signerAddress: Address,
    taskMaster: Address,
    _rewardAmountPerParticipantProxyInWei: bigint,
    _targetNumberOfParticipantProxies: bigint,
    _rewardToken: Address
  ): { deployData: Hex; salt: Hex } {
    const salt = toHex(randomBytes(32), { size: 32 });
  
    const args: readonly [Address, Address, bigint, bigint, Address] = [
      signerAddress,
      taskMaster,
      _rewardAmountPerParticipantProxyInWei,
      _targetNumberOfParticipantProxies,
      _rewardToken,
    ];
  
    const data = encodeDeployData({
      abi: taskManagerV1ABI,
      bytecode: taskManagerV1Bytecode,
      args,
    });
  
    const deployData = concat([salt, data]);
  
    return { deployData, salt };
  }
  
  // Find contract address from event logs
  export async function findContractAddressFromLogs(
    txHash: Hex,
    eventSignature: string,
    contractAddressFromTopic: boolean = true
  ): Promise<Address | undefined> {
    // Wait for the transaction receipt
    const receipt = await publicClient.getTransactionReceipt({
      hash: txHash,
    });
  
    // Convert event signature to topic hash
    const eventSignatureHash = calculateEventSignature(eventSignature);
  
    // Look through logs for our event
    for (const log of receipt.logs) {
      if (log.topics[0]?.toLowerCase() === eventSignatureHash.toLowerCase()) {
        // The contract address is in log.address
        const contractAddress = log.address as Address;
  
        if (contractAddressFromTopic) {
          // Additional verification: contract address should also be in indexed parameter
          const indexedAddress = `0x${(log.topics[1] ?? "").slice(-40)}`.toLowerCase();
          
          if (contractAddress.toLowerCase() === indexedAddress) {
            console.log(`Verified: Contract address ${contractAddress} matches indexed parameter`);
          } else {
            console.log(
              `Warning: Contract address ${contractAddress} doesn't match indexed parameter ${indexedAddress}`
            );
          }
        }
        
        return contractAddress;
      }
    }
    
    return undefined;
  }
  
  // Read contract state easily
  export async function readContractState(
    contractAddress: Address,
    abi: any,
    functionName: string,
    args: any[] = [],
    blockTag: BlockTag = 'latest'
  ): Promise<any> {
    return publicClient.readContract({
      address: contractAddress,
      abi,
      functionName,
      args,
      blockNumber: typeof blockTag === 'string' ? undefined : blockTag
    });
  }
  
  // Generate a random task ID
  export function generateRandomTaskId(): string {
    return `task-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
  }
  
  // Generate a random reward ID
  export function generateRandomRewardId(): string {
    return `reward-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
  }
  
  // Generate a random nonce
  export function generateRandomNonce(): bigint {
    return BigInt(Math.floor(Math.random() * 1000000));
  }


// Add this to your existing helpers file
export function loadDeployedAddresses() {
  try {
    const filePath = path.join(__dirname, '../deployments/addresses.json');
    if (fs.existsSync(filePath)) {
      const data = fs.readFileSync(filePath, 'utf8');
      return JSON.parse(data);
    } else {
      console.warn('Deployment addresses file not found. Using global variables.');
      return null;
    }
  } catch (error) {
    console.error('Error loading deployed addresses:', error);
    return null;
  }
}