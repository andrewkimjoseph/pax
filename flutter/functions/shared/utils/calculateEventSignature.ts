import { keccak256 } from "viem";

export function calculateEventSignature(eventSignatureString: string) {
  // Convert the string to bytes
  const encoder = new TextEncoder();
  const bytes = encoder.encode(eventSignatureString);

  // Calculate keccak256 hash
  const hash = keccak256(bytes);

  // Ensure proper formatting with 0x prefix
  return hash.toLowerCase();
}