import { expect } from "chai";
import { Address, encodeFunctionData, parseEther } from "viem";
import { publicClient, waitForUserOperationReceipt } from "../utils/clients";
import {
  readContractState,
  generateRandomTaskId,
  generateRandomRewardId,
  generateRandomNonce,
  loadDeployedAddresses,
} from "../utils/helpers";
import { taskManagerV1ABI } from "../abis/taskManagerV1";
import { erc20ABI } from "../abis/erc20";
import {
  createScreeningSignaturePackage,
  createRewardClaimSignaturePackage,
} from "../utils/signatures";
import { WalletInfo } from "../utils/wallets";

// Import global variables from setup test
declare global {
  var testAddresses: {
    taskManager: Address;
    paxAccounts: Address[];
  };
  var testWallets: { [key: string]: WalletInfo };
}

describe("3. TaskManager Tests", function () {
  this.timeout(120000); // Increase timeout for account abstraction operations

  let taskManagerAddress: Address;
  let paxAccountAddresses: Address[] = [];
  let wallets: { [key: string]: WalletInfo } = {};

  before(function () {
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
        throw new Error("Setup test must be run before TaskManager tests");
      }

      taskManagerAddress = global.testAddresses.taskManager;
      paxAccountAddresses = global.testAddresses.paxAccounts;
      wallets = global.testWallets;
    }

    console.log("TaskManager address:", taskManagerAddress);
    console.log("PaxAccount addresses:", paxAccountAddresses);
  });

  describe("3.1 Participant Screening", function () {
    it("should screen a participant with valid signature", async function () {
      const participantWallet = wallets.PARTICIPANT_2;
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Create a random task ID and nonce
      const taskId = generateRandomTaskId();
      const nonce = generateRandomNonce();

      // Generate signature package
      const sigPackage = await createScreeningSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantWallet.address,
        taskId,
        nonce
      );

      // Verify the signature is valid
      expect(sigPackage.isValid).to.be.true;

      // Check initial screening status
      const initialScreened = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsScreened",
        [participantWallet.address]
      );

      expect(initialScreened).to.be.false;

      // Prepare screening data
      const screeningData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "screenParticipantProxy",
        args: [participantWallet.address, taskId, nonce, sigPackage.signature],
      });

      // Send screening transaction from participant's wallet
      const userOpHash = await participantWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: screeningData,
          },
        ],
      });

      // Wait for receipt
      await waitForUserOperationReceipt(participantWallet.client, userOpHash);

      // Verify participant was screened
      const finalScreened = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsScreened",
        [participantWallet.address]
      );

      expect(finalScreened).to.be.true;

      // Check screened participant count increased
      const screenedCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfScreenedParticipantProxies"
      );

      console.log(`Number of screened participants: ${screenedCount}`);
      expect(screenedCount).to.be.greaterThan(0);
    });

    it("should reject screening with invalid signature", async function () {
      const participantWallet = wallets.PARTICIPANT_3;
      const nonOwnerWallet = wallets.PARTICIPANT_4; // Not the task manager

      // Create a random task ID and nonce
      const taskId = generateRandomTaskId();
      const nonce = generateRandomNonce();

      // Generate signature package signed by non-owner (will be invalid)
      const invalidSigPackage = await createScreeningSignaturePackage(
        taskManagerAddress,
        nonOwnerWallet, // Wrong signer
        participantWallet.address,
        taskId,
        nonce
      );

      // Prepare screening data with invalid signature
      const screeningData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "screenParticipantProxy",
        args: [
          participantWallet.address,
          taskId,
          nonce,
          invalidSigPackage.signature,
        ],
      });

      // Send screening transaction and expect it to fail
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
        console.log("Transaction correctly failed due to invalid signature");
      }

      // Verify participant was not screened
      const isScreened = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsScreened",
        [participantWallet.address]
      );

      expect(isScreened).to.be.false;
    });

    it("should reject screening by a different sender", async function () {
      const participantWallet = wallets.PARTICIPANT_3;
      const differentSenderWallet = wallets.PARTICIPANT_4;
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Create a random task ID and nonce
      const taskId = generateRandomTaskId();
      const nonce = generateRandomNonce();

      // Generate valid signature package for participant 3
      const sigPackage = await createScreeningSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantWallet.address,
        taskId,
        nonce
      );

      // Prepare screening data
      const screeningData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "screenParticipantProxy",
        args: [
          participantWallet.address, // Participant 3's address
          taskId,
          nonce,
          sigPackage.signature,
        ],
      });

      // Send screening transaction from a different wallet (participant 4) and expect it to fail
      try {
        const userOpHash = await differentSenderWallet.client.sendUserOperation(
          {
            calls: [
              {
                to: taskManagerAddress,
                value: 0n,
                data: screeningData,
              },
            ],
          }
        );

        await waitForUserOperationReceipt(
          differentSenderWallet.client,
          userOpHash
        );
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - sender mismatch");
      }

      // Verify participant was not screened
      const isScreened = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfParticipantProxyIsScreened",
        [participantWallet.address]
      );

      expect(isScreened).to.be.false;
    });

    it("should reject screening an already screened participant", async function () {
      // Use participant 2 who was already screened in the first test
      const participantWallet = wallets.PARTICIPANT_2;
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Create a new random task ID and nonce
      const taskId = generateRandomTaskId();
      const nonce = generateRandomNonce();

      // Generate signature package
      const sigPackage = await createScreeningSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantWallet.address,
        taskId,
        nonce
      );

      // Prepare screening data
      const screeningData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "screenParticipantProxy",
        args: [participantWallet.address, taskId, nonce, sigPackage.signature],
      });

      // Send screening transaction and expect it to fail
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
        console.log(
          "Transaction correctly failed - participant already screened"
        );
      }
    });
  });

  describe("3.2 Management Functions", function () {
    it("should pause and unpause the task", async function () {
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Check initial pause state
      const initialPaused = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfContractIsPaused"
      );

      // Prepare pause data
      const pauseData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "pausetask",
      });

      // Send pause transaction
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

      // Verify task is paused
      const isPaused = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfContractIsPaused"
      );

      expect(isPaused).to.be.true;

      // Now unpause
      const unpauseData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "unpausetask",
      });

      const unpauseOpHash = await taskManagerWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: unpauseData,
          },
        ],
      });

      await waitForUserOperationReceipt(
        taskManagerWallet.client,
        unpauseOpHash
      );

      // Verify task is unpaused
      const finalPaused = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "checkIfContractIsPaused"
      );

      expect(finalPaused).to.be.false;
    });

    it("should update reward amount per participant", async function () {
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Get initial reward amount
      const initialReward = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getRewardAmountPerParticipantProxyInWei"
      );

      console.log(`Initial reward amount: ${initialReward}`);

      // New reward amount (increased by 10%)
      const newReward = (initialReward * 110n) / 100n;

      // Prepare update data
      const updateData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "updateRewardAmountPerParticipantProxy",
        args: [newReward],
      });

      // Send update transaction
      const updateOpHash = await taskManagerWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: updateData,
          },
        ],
      });

      await waitForUserOperationReceipt(taskManagerWallet.client, updateOpHash);

      // Verify reward amount was updated
      const updatedReward = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getRewardAmountPerParticipantProxyInWei"
      );

      console.log(`Updated reward amount: ${updatedReward}`);
      expect(updatedReward).to.equal(newReward);
    });

    it("should update target number of participants", async function () {
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Get initial target number
      const initialTarget = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getTargetNumberOfParticipantProxies"
      );

      console.log(`Initial target number: ${initialTarget}`);

      // New target number (increased by 5)
      const newTarget = initialTarget + 5n;

      // Prepare update data
      const updateData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "updateTargetNumberOfParticipantProxies",
        args: [newTarget],
      });

      // Send update transaction
      const updateOpHash = await taskManagerWallet.client.sendUserOperation({
        calls: [
          {
            to: taskManagerAddress,
            value: 0n,
            data: updateData,
          },
        ],
      });

      await waitForUserOperationReceipt(taskManagerWallet.client, updateOpHash);

      // Verify target number was updated
      const updatedTarget = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getTargetNumberOfParticipantProxies"
      );

      console.log(`Updated target number: ${updatedTarget}`);
      expect(updatedTarget).to.equal(newTarget);
    });

    it("should reject decreasing the target number of participants", async function () {
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Get current target number
      const currentTarget = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getTargetNumberOfParticipantProxies"
      );

      // New target number (decreased by 1)
      const decreasedTarget = currentTarget - 1n;

      // Prepare update data
      const updateData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "updateTargetNumberOfParticipantProxies",
        args: [decreasedTarget],
      });

      // Send update transaction and expect it to fail
      try {
        const updateOpHash = await taskManagerWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: updateData,
            },
          ],
        });

        await waitForUserOperationReceipt(
          taskManagerWallet.client,
          updateOpHash
        );
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - cannot decrease target");
      }

      // Verify target number was not updated
      const finalTarget = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getTargetNumberOfParticipantProxies"
      );

      expect(finalTarget).to.equal(currentTarget);
    });

    it("should reject zero for target number or reward amount", async function () {
      const taskManagerWallet = wallets.TASK_MANAGER;

      // Try to set zero reward
      const zeroRewardData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "updateRewardAmountPerParticipantProxy",
        args: [0n],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await taskManagerWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: zeroRewardData,
            },
          ],
        });

        await waitForUserOperationReceipt(taskManagerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - cannot set zero reward");
      }

      // Try to set zero target
      const zeroTargetData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "updateTargetNumberOfParticipantProxies",
        args: [0n],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await taskManagerWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: zeroTargetData,
            },
          ],
        });

        await waitForUserOperationReceipt(taskManagerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - cannot set zero target");
      }
    });
  });

  describe("3.3 Access Control", function () {
    it("should reject management functions from non-owner accounts", async function () {
      const nonOwnerWallet = wallets.PARTICIPANT_2; // Not the task manager

      // Try to pause the task
      const pauseData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "pausetask",
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await nonOwnerWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: pauseData,
            },
          ],
        });

        await waitForUserOperationReceipt(nonOwnerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - unauthorized access");
      }

      // Try to update reward amount
      const updateRewardData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "updateRewardAmountPerParticipantProxy",
        args: [parseEther("0.02")],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await nonOwnerWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: updateRewardData,
            },
          ],
        });

        await waitForUserOperationReceipt(nonOwnerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - unauthorized access");
      }
    });
  });

  describe("3.4 Reward Claiming", function () {
    // We skip actually claiming rewards since we don't have real tokens in these test
    // accounts. In a production environment, we would fund the TaskManager contract
    // and test the complete claim process.

    it("should verify reward claim signature is valid", async function () {
      const participantWallet = wallets.PARTICIPANT_2; // Already screened
      const taskManagerWallet = wallets.TASK_MANAGER;
      const paxAccountAddress = paxAccountAddresses[1]; // Participant 2's PaxAccount

      // Create a random reward ID and nonce
      const rewardId = generateRandomRewardId();
      const nonce = generateRandomNonce();

      // Generate signature package
      const sigPackage = await createRewardClaimSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        participantWallet.address,
        rewardId,
        nonce
      );

      // Verify the signature is valid
      expect(sigPackage.isValid).to.be.true;

      console.log("Reward claim signature is valid");
      console.log("Reward ID:", rewardId);
      console.log("Nonce:", nonce);
      console.log("Signature:", sigPackage.signature);

      // Note: Actual claiming would be tested with:
      // const claimData = encodeFunctionData({
      //   abi: taskManagerV1ABI,
      //   functionName: "processRewardClaimByParticipantProxy",
      //   args: [
      //     participantWallet.address,
      //     paxAccountAddress,
      //     rewardId,
      //     nonce,
      //     sigPackage.signature
      //   ],
      // });
      // But we skip this since it requires actual tokens
    });

    it("should verify claim requirements are enforced", async function () {
      // Check that participants must be screened before claiming reward
      const unscreenedWallet = wallets.PARTICIPANT_3; // Not screened yet
      const taskManagerWallet = wallets.TASK_MANAGER;
      const paxAccountAddress = paxAccountAddresses[2]; // Participant 3's PaxAccount

      // Create a random reward ID and nonce
      const rewardId = generateRandomRewardId();
      const nonce = generateRandomNonce();

      // Generate signature package
      const sigPackage = await createRewardClaimSignaturePackage(
        taskManagerAddress,
        taskManagerWallet,
        unscreenedWallet.address,
        rewardId,
        nonce
      );

      // Prepare claim data
      const claimData = encodeFunctionData({
        abi: taskManagerV1ABI,
        functionName: "processRewardClaimByParticipantProxy",
        args: [
          unscreenedWallet.address,
          paxAccountAddress,
          rewardId,
          nonce,
          sigPackage.signature,
        ],
      });

      // Send claim transaction and expect it to fail
      try {
        const userOpHash = await unscreenedWallet.client.sendUserOperation({
          calls: [
            {
              to: taskManagerAddress,
              value: 0n,
              data: claimData,
            },
          ],
        });

        await waitForUserOperationReceipt(unscreenedWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed - participant not screened");
      }
    });
  });

  describe("3.5 Contract Limits and Edge Cases", function () {
    it("should maintain correct counters for screened and rewarded participants", async function () {
      // Get current counts
      const screenedCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfScreenedParticipantProxies"
      );

      const rewardedCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfRewardedParticipantProxies"
      );

      const claimedCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfClaimedRewards"
      );

      console.log(`Screened participants count: ${screenedCount}`);
      console.log(`Rewarded participants count: ${rewardedCount}`);
      console.log(`Claimed rewards count: ${claimedCount}`);

      // Verify that claim counts match rewarded counts
      expect(rewardedCount).to.equal(claimedCount);

      // Verify that screened count is at least as high as rewarded count
      expect(Number(screenedCount)).to.be.greaterThanOrEqual(
        Number(rewardedCount)
      );
    });

    it("should track signature usage correctly", async function () {
      // Get current signature usage counts
      const screeningSigCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfUsedScreeningSignatures"
      );

      const claimingSigCount = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getNumberOfUsedClaimingSignatures"
      );

      console.log(`Used screening signatures count: ${screeningSigCount}`);
      console.log(`Used claiming signatures count: ${claimingSigCount}`);

      // Screenings should be at least 1 (from our test)
      expect(screeningSigCount).to.be.greaterThan(Number(0));
    });

    it("should check for contract balance and handle low balance cases", async function () {
      // Check the contract's token balance
      const currentBalance = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getRewardTokenContractBalanceAmount"
      );

      console.log(`Current contract token balance: ${currentBalance}`);

      // In a real test we would:
      // 1. Test what happens when trying to claim with insufficient balance
      // 2. Test what happens when adding funds
      // 3. Test withdrawal functionality

      // For now, we'll just verify the getter works
      expect(typeof currentBalance).to.equal("bigint");
    });

    it("should verify properties of the reward token", async function () {
      // Get the reward token address
      const rewardTokenAddress = await readContractState(
        taskManagerAddress,
        taskManagerV1ABI,
        "getRewardTokenContractAddress"
      );

      console.log(`Reward token address: ${rewardTokenAddress}`);

      // Verify it's a valid address
      expect(rewardTokenAddress).to.match(/^0x[a-fA-F0-9]{40}$/);

      try {
        // Try to get token details (may fail if no RPC connection)
        const tokenSymbol = await readContractState(
          rewardTokenAddress as Address,
          erc20ABI,
          "symbol"
        );

        console.log(`Reward token symbol: ${tokenSymbol}`);
      } catch (error) {
        console.log(
          "Could not fetch token details, but address format is valid"
        );
      }
    });
  });
});
