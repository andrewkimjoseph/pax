import { erc1967ProxyABI } from "../../utils/abis/erc1967Proxy";
import { paxAccountV1ABI } from "../../utils/abis/paxAccountV1ABI";
import { Address, concat, encodeDeployData, encodeFunctionData, Hex, toHex } from "viem";
import { randomBytes } from "crypto";
import { erc1967ByteCode } from "../bytecode/erc1967";
 // Function to generate deterministic deployment data with salt
 export function getProxyDeployDataAndSalt(
  implementationAddress: Address,
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
    args: [implementationAddress, initData],
  });

  // Combine the salt with the deployment data
  const deployData = concat([salt, proxyData]);

  return { deployData, salt };
}

