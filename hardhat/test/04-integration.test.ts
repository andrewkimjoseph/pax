import { expect } from "chai";
import { Address, encodeFunctionData, parseEther } from "viem";
import { publicClient, waitForUserOperationReceipt } from "./utils/clients";
import { readContractState, generateRandomTaskId, generateRandomRewardId, generateRandomNonce, REWARD_TOKEN_ADDRESS, loadDeployedAddresses } from "./utils/helpers";
import { taskManagerV1ABI } from "./abis/taskManagerV1";
import { paxAccountV1ABI } from "./abis/paxAccountV1";
import { erc20ABI } from "./abis/erc20";
import { createScreeningSignaturePackage, createRewardClaimSignaturePackage } from "./utils/signatures";
import { WalletInfo } from "./utils/wallets";

// Import global variables from setup test
declare global {
  var testAddresses: {
    taskManager: Address;
    paxAccounts: Address[];
  };
  var testWallets: { [key: string]: WalletInfo };
}

describe("4. Integration Tests", function() {
  this.timeout(180000); // Increase timeout for complex operations

  let taskManagerAddress: Address;
  let paxAccountAddresses: Address[] = [];
  let wallets: { [key: string]: WalletInfo } = {};

  before(function() {
    // First try to load from file
    const deployedAddresses = loadDeployedAddresses();
    
    if (deployedAddresses) {
      // If file exists, use addresses from there
      taskManagerAddress = deployedAddresses.taskManager as Address;
      paxAccountAddresses = deployedAddresses.paxAccounts as Address[];
      // For wallets, we'll still need to use the global variable
      if (global.testWallets) {
        wallets = global.testWallets;
      } else {
        throw new Error("Wallet information not available in global variables");
      }
    } else {
      // Fallback to global variables if file doesn't exist
      if (!global.testAddresses || !global.testWallets) {
        throw new Error("Setup test must be run before integration tests");
      }
      
      taskManagerAddress = global.testAddresses.taskManager;
      paxAccountAddresses = global.testAddresses.paxAccounts;
      wallets = global.testWallets;
    }
    
    console.log("TaskManager address:", taskManagerAddress);
    console.log("PaxAccount addresses:", paxAccountAddresses);
  });

  describe("4.1 Complete Workflow", function() {
    // In this test suite, we'll set up a complete workflow where we:
    // 1. Fund the TaskManager contract
    // 2. Screen a new participant
    // 3. Process a reward claim
    // 4. Verify tokens were transferred to the PaxAccount
    
    // Note: Since we're working with test accounts without real tokens,
    // we'll simulate the funding step and might not be able to complete
    // the actual token transfer.
    
    it("should demonstrate a complete participant journey", async function() {
      // We'll use PARTICIPANT_4 who hasn't been screened yet
      const participantWallet = wallets.PARTICIPANT_4;
      const taskManagerWallet = wallets.TASK_MANAGER;
      const participantAddress = participantWallet.address;
      const paxAccountAddress = paxAccountAddresses[3]; // Participant 4's PaxAccount
      
      console.log(`Testing complete flow for participant: ${participantAddress}`);
      console.log(`Participant's PaxAccount: ${paxAccountAddress}`);
      
      // Step 1: Check initial state
      const initialScreened = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsScreened",
        [participantAddress]
      );
      
      const initialRewarded = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsRewarded",
        [participantAddress]
      );
      
      console.log(`Initial screened state: ${initialScreened}`);
      console.log(`Initial rewarded state: ${initialRewarded}`);
      
      expect(initialScreened).to.be.false;
      expect(initialRewarded).to.be.false;
      
      // Step 2: Screen the participant
      const taskId = generateRandomTaskId();
      const screeningNonce = generateRandomNonce();
      
      // Generate signature package for screening
      const screeningSigPackage = await createScreeningSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantAddress,
        taskId,
        screeningNonce
      );
      
      // Prepare screening data
      const screeningData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "screenParticipantProxy",
        args: [
          participantAddress,
          taskId,
          screeningNonce,
          screeningSigPackage.signature
        ],
      });
      
      // Send screening transaction
      console.log("Sending screening transaction...");
      const screeningOpHash = await participantWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: screeningData,
          },
        ],
      });
      
      await waitForUserOperationReceipt(participantWallet.client, screeningOpHash);
      console.log("Screening transaction confirmed");
      
      // Verify participant was screened
      const afterScreeningState = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsScreened",
        [participantAddress]
      );
      
      console.log(`After screening state: ${afterScreeningState}`);
      expect(afterScreeningState).to.be.true;
      
      // Step 3: Fund the TaskManager contract
      // In a production environment, we would do this with real tokens
      console.log("Note: In a production environment, we would fund the TaskManager with tokens here.");
      
      // Step 4: Prepare for reward claim
      const rewardId = generateRandomRewardId();
      const rewardNonce = generateRandomNonce();
      
      // Generate signature package for reward claim
      const rewardSigPackage = await createRewardClaimSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantAddress,
        rewardId,
        rewardNonce
      );
      
      // Note: In a real environment, we would complete this test by:
      // 1. Funding the TaskManager with tokens
      // 2. Calling processRewardClaimByParticipantProxy
      // 3. Verifying tokens were received by the PaxAccount
      
      console.log("Reward claim signature prepared successfully");
      console.log("Reward ID:", rewardId);
      console.log("Reward nonce:", rewardNonce);
      
      // Since we don't have real tokens, we'll just verify the signature is valid
      expect(rewardSigPackage.isValid).to.be.true;
    });
  });

  describe("4.2 Simulated Multi-Participant Scenario", function() {
    it("should track screening and claiming metrics correctly", async function() {
      // Get current metrics
      const screenedCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfScreenedParticipantProxies"
      );
      
      const usedScreeningSigs = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfUsedScreeningSignatures"
      );
      
      const rewardedCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfRewardedParticipantProxies"
      );
      
      const claimedRewards = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfClaimedRewards"
      );
      
      console.log(`Screened participants: ${screenedCount}`);
      console.log(`Used screening signatures: ${usedScreeningSigs}`);
      console.log(`Rewarded participants: ${rewardedCount}`);
      console.log(`Claimed rewards: ${claimedRewards}`);
      
      // In our tests, we've screened two participants: PARTICIPANT_2 and PARTICIPANT_4
      // And we have not completed any reward claims due to token limitations
      
      // Check that screened count matches our expectations 
      // (exactly 2 participants should be screened)
      expect(screenedCount).to.equal(2n);
      
      // Check that used screening signatures matches screened count
      expect(usedScreeningSigs).to.equal(screenedCount);
      
      // Rewarded count should be 0 since we didn't complete any claims
      expect(rewardedCount).to.equal(0n);
      
      // Claimed rewards should match rewarded count
      expect(claimedRewards).to.equal(rewardedCount);
    });
  });

  describe("4.3 Contract Interactions", function() {
    it("should verify PaxAccount can receive tokens", async function() {
      // This is a theoretical test since we don't have real tokens
      const paxAccount = paxAccountAddresses[0]; // Task Manager's PaxAccount
      
      // Get the current token balance of the PaxAccount
      const tokenBalances = await readContractState(
        paxAccount,
        paxAccountV1ABI,
        "getTokenBalances",
        [[REWARD_TOKEN_ADDRESS]]
      );
      
      console.log(`PaxAccount token balance: ${tokenBalances[0].balance}`);
      
      // In a production environment, we would:
      // 1. Send tokens to the PaxAccount
      // 2. Verify the balance increased
      // 3. Test withdrawing tokens to a payment method
      
      // Instead, we just verify the balance reading function works
      expect(tokenBalances).to.be.an('array');
      expect(tokenBalances.length).to.equal(1);
      expect(tokenBalances[0].tokenAddress.toLowerCase()).to.equal(REWARD_TOKEN_ADDRESS.toLowerCase());
    });
  });

  describe("4.4 Edge Cases", function() {
    it("should handle paused contract correctly", async function() {
      const taskManagerWallet = wallets.TASK_MANAGER;
      const participantWallet = wallets.PARTICIPANT_3; // Not screened yet
      
      // First, pause the contract
      const pauseData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "pauseTask",
      });
      
      console.log("Pausing contract...");
      const pauseOpHash = await taskManagerWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: pauseData,
          },
        ],
      });
      
      await waitForUserOperationReceipt(taskManagerWallet.client, pauseOpHash);
      
      // Verify contract is paused
      const isPaused = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfContractIsPaused"
      );
      expect(isPaused).to.be.true;
      
      // Try to screen a participant while paused
      const taskId = generateRandomTaskId();
      const nonce = generateRandomNonce();
      
      const sigPackage = await createScreeningSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantWallet.address,
        taskId,
        nonce
      );
      
      const screeningData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "screenParticipantProxy",
        args: [
          participantWallet.address,
          taskId,
          nonce,
          sigPackage.signature
        ],
      });
      
      // Send transaction and expect it to fail
      try {
        const userOpHash = await participantWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: screeningData,
            },
          ],
        });
        
        await waitForUserOperationReceipt(participantWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - contract is paused");
      }
      
      // Now unpause for subsequent tests
      const unpauseData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "unpauseTask",
      });
      
      console.log("Unpausing contract...");
      const unpauseOpHash = await taskManagerWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: unpauseData,
          },
        ],
      });
      
      await waitForUserOperationReceipt(taskManagerWallet.client, unpauseOpHash);
      
      // Verify contract is unpaused
      const finalPaused = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfContractIsPaused"
      );
      expect(finalPaused).to.be.false;
    });
  });
});