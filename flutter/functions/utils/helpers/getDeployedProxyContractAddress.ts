import { logger } from "firebase-functions";
import { calculateEventSignature } from "./calculateEventSignature";
import { PUBLIC_CLIENT } from "../config";
import { Address } from "viem";

// Helper function to extract the proxy address from transaction logs
export async function getDeployedProxyContractAddress(
    txHash: Address
  ): Promise<Address | undefined> {
    try {
      // Wait for the transaction receipt
      const receipt = await PUBLIC_CLIENT.getTransactionReceipt({
        hash: txHash,
      });
  
      // The specific event signature for PaxAccountCreated(address)
      const paxAccountEventSignature = calculateEventSignature(
        "PaxAccountCreated(address)"
      );
  
      // Look through all logs for our specific event
      for (const log of receipt.logs) {
        if (
          log.topics[0]?.toLowerCase() === paxAccountEventSignature.toLowerCase()
        ) {
          // The contract address is in log.address
          const contractAddress = log.address as Address;
  
          logger.info(`Found PaxAccount contract at address: ${contractAddress}`);
  
          // Additional verification: the contract address should also be in the indexed parameter
          if (log.topics[1]) {
            const indexedAddress = `0x${log.topics[1].slice(
              -40
            )}`.toLowerCase() as Address;
  
            if (contractAddress.toLowerCase() === indexedAddress.toLowerCase()) {
              logger.info(
                `Verified: The indexed parameter matches the contract address`
              );
            } else {
              logger.warn(
                `Warning: Contract address ${contractAddress} doesn't match indexed parameter ${indexedAddress}`
              );
            }
          }
  
          return contractAddress;
        }
      }
  
      return undefined;
    } catch (error) {
      logger.error("Error retrieving contract address from logs", {
        error,
        txHash,
      });
      throw error;
    }
  }
  