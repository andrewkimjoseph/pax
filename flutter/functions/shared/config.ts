import { Address, createPublicClient, http } from 'viem';
import { CallableOptions } from 'firebase-functions/v2/https';
import { config } from 'dotenv';
import { celo } from 'viem/chains';
import { PrivyClient } from '@privy-io/server-auth';
import * as admin from "firebase-admin";

config();

export const PRIVY_APP_ID = process.env.PRIVY_APP_ID || '';
export const PRIVY_APP_SECRET = process.env.PRIVY_APP_SECRET || '';
export const PRIVY_WALLET_AUTH_PRIVATE_KEY = process.env.PRIVY_WALLET_AUTH_PRIVATE_KEY || '';
export const PIMLICO_API_KEY = process.env.PIMLICO_API_KEY || '';
export const PAX_MASTER = `0x${process.env.PAX_MASTER}` as Address;
export const PAXACCOUNT_IMPLEMENTATION_ADDRESS = process.env.PAXACCOUNT_IMPLEMENTATION_ADDRESS as Address;


export const FUNCTION_RUNTIME_OPTS: CallableOptions = {
  // timeoutSeconds: 300,
  // memory: '1GiB', // Using the proper memory string value
};

admin.initializeApp();

// Contract addresses
export const CREATE2_FACTORY = "0x4e59b44847b379578588920cA78FbF26c0B4956C" as Address;

// API endpoint configs
export const PIMLICO_URL = `https://api.pimlico.io/v2/42220/rpc?apikey=${PIMLICO_API_KEY}`;

export const REWARD_TOKEN_ADDRESS = "0x62B8B11039FcfE5aB0C56E502b1C372A3d2a9c7A" as Address;

export const PUBLIC_CLIENT = createPublicClient({
  chain: celo,
  transport: http(),
});



export const PRIVY_CLIENT = new PrivyClient(PRIVY_APP_ID, PRIVY_APP_SECRET, {
  walletApi: {
    authorizationPrivateKey: PRIVY_WALLET_AUTH_PRIVATE_KEY,
  },
});

export const DB = admin.firestore;

export const MESSAGING = admin.messaging();