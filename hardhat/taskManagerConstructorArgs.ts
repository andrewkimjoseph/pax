import { Address, parseEther } from "viem";


export const taskManagerConstructorArgs: [Address, BigInt, BigInt, Address] = [
  "0xE49B05F2c7DD51f61E415E1DFAc10B80074B001A",
  // parseEther("0.01"), // 0.01 cUSD
  parseEther("2000"), // 3,000 G$
  // BigInt(3), // 3 people
  BigInt(50), // 50 people
  // "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1", // Celo Dollar Alfajores
  "0x62B8B11039FcfE5aB0C56E502b1C372A3d2a9c7A", // Good Dollar Token Mainnet
];
