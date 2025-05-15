import { Address } from 'viem';
import { CallableOptions } from 'firebase-functions/v2/https';
import { config } from 'dotenv';


config();

// Environment variables
export const PRIVY_APP_ID = process.env.PRIVY_APP_ID || '';
export const PRIVY_APP_SECRET = process.env.PRIVY_APP_SECRET || '';
export const PRIVY_WALLET_AUTH_PRIVATE_KEY = process.env.PRIVY_WALLET_AUTH_PRIVATE_KEY || '';
export const PIMLICO_API_KEY = process.env.PIMLICO_API_KEY || '';
export const PAXACCOUNT_IMPLEMENTATION_ADDRESS = process.env.PAXACCOUNT_IMPLEMENTATION_ADDRESS as Address;

// Function runtime options
export const FUNCTION_RUNTIME_OPTS: CallableOptions = {
  // timeoutSeconds: 300,
  // memory: '1GiB', // Using the proper memory string value
};

// Contract addresses
export const CREATE2_FACTORY = "0x4e59b44847b379578588920cA78FbF26c0B4956C" as Address;

// API endpoint configs
export const PIMLICO_URL = `https://api.pimlico.io/v2/42220/rpc?apikey=${PIMLICO_API_KEY}`;