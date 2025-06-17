import * as fs from "fs";
import * as path from "path";
import { expect } from "chai";
import { Address, parseEther } from "viem";
import { WALLET_IDS, getWalletInfo, WalletInfo } from "./utils/wallets";

// import { participantOne, participantThree, participantTwo, publicClient } from "./utils/clients";
import { taskManagerV1ABI } from "./abis/taskManagerV1";
import { paxAccountV1ABI } from "./abis/paxAccountV1";
import { readContractState, REWARD_TOKEN_ADDRESS } from "./utils/helpers";
import { erc20ABI } from "./abis/erc20";
import { deployTaskManager } from "./deploy/deployTaskManager";
import { deployPaxAccountProxy } from "./deploy/deployPaxAccount";

// Global variables to store deployed contract addresses
let taskManagerAddress: Address;
let paxAccountAddresses: Address[] = [];
let wallets: { [key: string]: WalletInfo } = {};

// Function to save addresses to a JSON file
function saveAddressesToFile() {
  try {
    // Create deployment data object
    const deploymentData = {
      taskManager: taskManagerAddress,
      paxAccounts: paxAccountAddresses,
      walletAddresses: {
        taskManager: wallets.TASK_MANAGER.address,
  participant2: wallets.PARTICIPANT_2.address,
        participant3: wallets.PARTICIPANT_3.address,
        participant4: wallets.PARTICIPANT_4.address
      },
      rewardToken: REWARD_TOKEN_ADDRESS,
      timestamp: new Date().toISOString(),
      network: "celo", // You may want to make this dynamic
    };

    // Create deployments directory if it doesn't exist
    const deploymentsDir = path.join(__dirname, "./deployments");
    if (!fs.existsSync(deploymentsDir)) {
      fs.mkdirSync(deploymentsDir, { recursive: true });
    }

    // Write to JSON file
    const filePath = path.join(deploymentsDir, "addresses.json");
    fs.writeFileSync(filePath, JSON.stringify(deploymentData, null, 2));

    console.log(`Deployment addresses saved to: ${filePath}`);
  } catch (error) {
    console.error("Error saving addresses to file:", error);
  }
}

describe("1. Initial Setup Tests", function () {
  this.timeout(120000); // Allow up to 2 minutes for these tests due to account abstraction overhead

  before(async function () {
    // Setup all wallet accounts
    console.log("Setting up wallet accounts...");
    wallets.TASK_MANAGER = await getWalletInfo(WALLET_IDS.TASK_MANAGER, true);
    // wallets.PARTICIPANT_2 = await getWalletInfo(WALLET_IDS.PARTICIPANT_2, false);
    // wallets.PARTICIPANT_3 = await getWalletInfo(WALLET_IDS.PARTICIPANT_3, false);
    // wallets.PARTICIPANT_4 = await getWalletInfo(WALLET_IDS.PARTICIPANT_4, false);

    // console.log("Task Manager wallet address:", wallets.TASK_MANAGER.address);
    // console.log("Participant 2 wallet address:", wallets.PARTICIPANT_2.address);
    // console.log("Participant 3 wallet address:", wallets.PARTICIPANT_3.address);
    // console.log("Participant 4 wallet address:", wallets.PARTICIPANT_4.address);
  });

  // it("should create Smart Accounts successfully", async function () {
  //   expect(wallets.TASK_MANAGER.address).to.match(/^0x[a-fA-F0-9]{40}$/);
  //   expect(wallets.PARTICIPANT_2.address).to.match(/^0x[a-fA-F0-9]{40}$/);
  //   expect(wallets.PARTICIPANT_3.address).to.match(/^0x[a-fA-F0-9]{40}$/);
  //   expect(wallets.PARTICIPANT_4.address).to.match(/^0x[a-fA-F0-9]{40}$/);
  // });

  it("should deploy TaskManager contract", async function () {
    // Deploy TaskManager with default parameters
    taskManagerAddress = await deployTaskManager(
      wallets.TASK_MANAGER,
      parseEther("0.25"), // 0.01 cUSD per participant
      15n // 5 target participants
    );

    expect(taskManagerAddress).to.match(/^0x[a-fA-F0-9]{40}$/);

    // Verify the TaskManager is owned by the correct address
    const owner = await readContractState(
      taskManagerAddress,
      taskManagerV1ABI,
      "getOwner"
    );

    expect(owner.toLowerCase()).to.equal(
      wallets.TASK_MANAGER.safeSmartAccount.address.toLowerCase()
    );
  });

  // it("should deploy PaxAccount proxies for all participants", async function() {
  //   // Deploy PaxAccount for Task Manager / Participant 1
  //   const paxAccount1 = await deployPaxAccountProxy(
  //     wallets.TASK_MANAGER,
  //     "0x96a6086f14A4FEf488d36fd1F0F175A639315e56" // Use its own address as primary payment method
  //   );
  //   paxAccountAddresses.push(paxAccount1);

  //   // Deploy PaxAccount for Participant 2
  //   // const paxAccount2 = await deployPaxAccountProxy(
  //   //   wallets.PARTICIPANT_2,
  //   //   wallets.PARTICIPANT_2.address // Use its own address as primary payment method
  //   // );
  //   // paxAccountAddresses.push(paxAccount2);

  //   // // Deploy PaxAccount for Participant 3
  //   // const paxAccount3 = await deployPaxAccountProxy(
  //   //   wallets.PARTICIPANT_3,
  //   //   wallets.PARTICIPANT_3.address // Use its own address as primary payment method
  //   // );
  //   // paxAccountAddresses.push(paxAccount3);

  //   // // Deploy PaxAccount for Participant 4
  //   // const paxAccount4 = await deployPaxAccountProxy(
  //   //   wallets.PARTICIPANT_4,
  //   //   wallets.PARTICIPANT_4.address // Use its own address as primary payment method
  //   // );
  //   // paxAccountAddresses.push(paxAccount4);

  //   // Verify all PaxAccounts were deployed successfully
  //   expect(paxAccountAddresses.length).to.equal(4);

  //   for (const address of paxAccountAddresses) {
  //     expect(address).to.match(/^0x[a-fA-F0-9]{40}$/);
  //   }

  //   // Save the addresses after successful deployment
  //   saveAddressesToFile();
  // });

  // // Rest of the tests remain the same...

  // it("should verify PaxAccount initialization parameters", async function () {
  //   // Check each PaxAccount's owner and primary payment method
  //   for (let i = 0; i < paxAccountAddresses.length; i++) {
  //     const paxAccountAddress = paxAccountAddresses[i];
  //     const walletKey = i === 0 ? "TASK_MANAGER" : `PARTICIPANT_${i + 1}`;
  //     const wallet = wallets[walletKey];

  //     // Verify owner
  //     const owner = await readContractState(
  //       paxAccountAddress,
  //       paxAccountV1ABI,
  //       "owner"
  //     );
  //     expect(owner.toLowerCase()).to.equal(wallet.address.toLowerCase());

  //     // Verify primary payment method
  //     const primaryPaymentMethod = await readContractState(
  //       paxAccountAddress,
  //       paxAccountV1ABI,
  //       "getPrimaryPaymentMethod"
  //     );
  //     expect(primaryPaymentMethod.toLowerCase()).to.equal(
  //       wallet.address.toLowerCase()
  //     );
  //   }
  // });

  // it("should verify TaskManager configuration", async function () {
  //   // Check reward amount
  //   const rewardAmount = await readContractState(
  //     taskManagerAddress,
  //     taskManagerV1ABI,
  //     "getRewardAmountPerParticipantProxyInWei"
  //   );
  //   expect(rewardAmount).to.equal(parseEther("0.01"));

  //   // Check target participants
  //   const targetParticipants = await readContractState(
  //     taskManagerAddress,
  //     taskManagerV1ABI,
  //     "getTargetNumberOfParticipantProxies"
  //   );
  //   expect(targetParticipants).to.equal(5n);

  //   // Check reward token
  //   const rewardToken = await readContractState(
  //     taskManagerAddress,
  //     taskManagerV1ABI,
  //     "getRewardTokenContractAddress"
  //   );
  //   expect(rewardToken.toLowerCase()).to.equal(
  //     REWARD_TOKEN_ADDRESS.toLowerCase()
  //   );
  // });

  // it("should fund the TaskManager with reward tokens", async function () {
  //   // For testing purposes, we'll skip the actual funding transaction since it requires real tokens.
  //   // In a production environment, we would send cUSD to the TaskManager contract here.

  //   // Instead, we'll just check the current balance
  //   const balance = await readContractState(
  //     taskManagerAddress,
  //     taskManagerV1ABI,
  //     "getRewardTokenContractBalanceAmount"
  //   );

  //   console.log(`TaskManager contract balance: ${balance} wei`);
  //   // We don't assert anything here since we're not actually funding it
  // });

  // // Export variables for use in other test files
  // after(function () {
  //   // Write contract addresses to a global object that can be imported by other test files
  //   global.testAddresses = {
  //     taskManager: taskManagerAddress,
  //     paxAccounts: paxAccountAddresses,
  //   };

  //   global.testWallets = wallets;

  //   // Save addresses to file again in case any addresses were updated during tests
  //   saveAddressesToFile();

  //   console.log("Setup completed successfully!");
  //   console.log("TaskManager address:", taskManagerAddress);
  //   console.log("PaxAccount addresses:", paxAccountAddresses);
  // });
});
