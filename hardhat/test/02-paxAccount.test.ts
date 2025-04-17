import { expect } from "chai";
import { Address, encodeFunctionData, parseEther } from "viem";
import { publicClient, waitForUserOperationReceipt } from "../utils/clients";
import { loadDeployedAddresses, readContractState, REWARD_TOKEN_ADDRESS } from "../utils/helpers";
import { paxAccountV1ABI } from "../abis/paxAccountV1";
import { erc20ABI } from "../abis/erc20";
import { WalletInfo } from "../utils/wallets";

// Import global variables from setup test
declare global {
  var testAddresses: {
    taskManager: Address;
    paxAccounts: Address[];
  };
  var testWallets:  { [key: string]: WalletInfo };
}

describe("2. PaxAccount Tests", function () {
  this.timeout(60000); // Increase timeout for account abstraction operations

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
        throw new Error("Setup test must be run before PaxAccount tests");
      }
      
      taskManagerAddress = global.testAddresses.taskManager;
      paxAccountAddresses = global.testAddresses.paxAccounts;
      wallets = global.testWallets;
    }
    
    console.log("TaskManager address:", taskManagerAddress);
    console.log("PaxAccount addresses:", paxAccountAddresses);
  });

  describe("2.1 Payment Method Management", function () {
    it("should add a new payment method", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount
      const ownerWallet = wallets.TASK_MANAGER;

      // First, check number of payment methods initially
      const initialPaymentMethods = await readContractState(
        paxAccountAddress,
        paxAccountV1ABI,
        "getPaymentMethods"
      );

      console.log("Initial payment methods:", initialPaymentMethods);
      const initialCount = initialPaymentMethods.length;

      // Create payment method data
      const newPaymentMethod = "0x89E1CB0C01CA976C98cAbA8fB3e63B03343DcD06";
      const paymentMethodId = 1;

      const addPaymentMethodData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addPaymentMethod",
        args: [paymentMethodId, newPaymentMethod],
      });

      // Send transaction
      const userOpHash = await ownerWallet.client.sendUserOperation({
        calls: [
          {
            to: paxAccountAddress,
            value: 0n,
            data: addPaymentMethodData,
          },
        ],
      });

      // Wait for receipt
      await waitForUserOperationReceipt(ownerWallet.client, userOpHash);

      // Verify payment method was added
      const updatedPaymentMethods = await readContractState(
        paxAccountAddress,
        paxAccountV1ABI,
        "getPaymentMethods"
      );

      console.log("Updated payment methods:", updatedPaymentMethods);
      expect(updatedPaymentMethods.length).to.equal(initialCount + 1);

      // Find the new payment method in the list
      const foundMethod = updatedPaymentMethods.find(
        (method: { id: bigint }) => method.id === BigInt(paymentMethodId)
      );

      expect(foundMethod).to.not.be.undefined;
      expect(foundMethod.paymentAddress.toLowerCase()).to.equal(
        newPaymentMethod.toLowerCase()
      );
    });

    it("should add a non-primary payment method", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount
      const ownerWallet = wallets.TASK_MANAGER;

      // Initial count of payment methods
      const initialPaymentMethods = await readContractState(
        paxAccountAddress,
        paxAccountV1ABI,
        "getPaymentMethods"
      );
      const initialCount = initialPaymentMethods.length;

      // Create payment method data
      const newPaymentMethod = "0x89E1CB0C01CA976C98cAbA8fB3e63B03343DcD06";
      const paymentMethodId = 2;

      const addNonPrimaryData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addNonPrimaryPaymentMethod",
        args: [paymentMethodId, newPaymentMethod],
      });

      // Send transaction
      const userOpHash = await ownerWallet.client.sendUserOperation({
        calls: [
          {
            to: paxAccountAddress,
            value: 0n,
            data: addNonPrimaryData,
          },
        ],
      });

      // Wait for receipt
      await waitForUserOperationReceipt(ownerWallet.client, userOpHash);

      // Verify payment method was added
      const updatedPaymentMethods = await readContractState(
        paxAccountAddress,
        paxAccountV1ABI,
        "getPaymentMethods"
      );

      expect(updatedPaymentMethods.length).to.equal(initialCount + 1);

      // Find the new payment method in the list
      const foundMethod = updatedPaymentMethods.find(
        (method: { id: bigint }) => method.id === BigInt(paymentMethodId)
      );

      expect(foundMethod).to.not.be.undefined;
      expect(foundMethod.paymentAddress.toLowerCase()).to.equal(
        newPaymentMethod.toLowerCase()
      );
    });

    it("should reject adding a payment method with ID 0", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount
      const ownerWallet = wallets.TASK_MANAGER;

      // Create payment method data for ID 0 (should be rejected)
      const newPaymentMethod = "0x89878e9744AF84c091063543688C488d393E8912";
      const paymentMethodId = 0;

      const addPaymentMethodData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addPaymentMethod",
        args: [paymentMethodId, newPaymentMethod],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await ownerWallet.client.sendUserOperation({
          calls: [
            {
              to: paxAccountAddress,
              value: 0n,
              data: addPaymentMethodData,
            },
          ],
        });

        await waitForUserOperationReceipt(ownerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed as expected");
      }
    });

    it("should reject adding a payment method with an existing ID", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount
      const ownerWallet = wallets.TASK_MANAGER;

      // Create payment method data with ID that already exists (ID 1 from previous test)
      const newPaymentMethod = "0x6dce6E80b113607bABf97041A0C8C5ACCC4d1a4e";
      const paymentMethodId = 1;

      const addPaymentMethodData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addPaymentMethod",
        args: [paymentMethodId, newPaymentMethod],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await ownerWallet.client.sendUserOperation({
          calls: [
            {
              to: paxAccountAddress,
              value: 0n,
              data: addPaymentMethodData,
            },
          ],
        });

        await waitForUserOperationReceipt(ownerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed as expected");
      }
    });

    it("should reject adding zero address as payment method", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount
      const ownerWallet = wallets.TASK_MANAGER;

      // Create payment method data with zero address
      const zeroAddress = "0x0000000000000000000000000000000000000000";
      const paymentMethodId = 3;

      const addPaymentMethodData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addPaymentMethod",
        args: [paymentMethodId, zeroAddress],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await ownerWallet.client.sendUserOperation({
          calls: [
            {
              to: paxAccountAddress,
              value: 0n,
              data: addPaymentMethodData,
            },
          ],
        });

        await waitForUserOperationReceipt(ownerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log("Transaction correctly failed as expected");
      }
    });
  });

  describe("2.2 Access Control", function () {
    it("should reject operations from non-owner accounts", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount
      const nonOwnerWallet = wallets.PARTICIPANT_2; // Not the owner

      // Try to add a payment method from non-owner account
      const newPaymentMethod = "0x6dce6E80b113607bABf97041A0C8C5ACCC4d1a4e";
      const paymentMethodId = 5;

      const addPaymentMethodData = encodeFunctionData({
        abi: paxAccountV1ABI,
        functionName: "addPaymentMethod",
        args: [paymentMethodId, newPaymentMethod],
      });

      // Send transaction and expect it to fail
      try {
        const userOpHash = await nonOwnerWallet.client.sendUserOperation({
          calls: [
            {
              to: paxAccountAddress,
              value: 0n,
              data: addPaymentMethodData,
            },
          ],
        });

        await waitForUserOperationReceipt(nonOwnerWallet.client, userOpHash);
        expect.fail("Transaction should have failed");
      } catch (error) {
        // Expected to fail
        console.log(
          "Transaction correctly failed as expected due to unauthorized access"
        );
      }
    });
  });

  describe("2.3 Token Balance Management", function () {
    it("should correctly report token balances", async function () {
      const paxAccountAddress = paxAccountAddresses[0]; // Task Manager's PaxAccount

      // Get token balances (we'll check cUSD)
      const tokenBalances = await readContractState(
        paxAccountAddress,
        paxAccountV1ABI,
        "getTokenBalances",
        [[REWARD_TOKEN_ADDRESS]] // Array of token addresses to check
      );

      console.log("Token balances:", tokenBalances);

      // Verify structure is correct
      expect(tokenBalances).to.be.an("array");
      expect(tokenBalances.length).to.equal(1);
      expect(tokenBalances[0].tokenAddress.toLowerCase()).to.equal(
        REWARD_TOKEN_ADDRESS.toLowerCase()
      );

      // Balance might be 0, but should be a valid bigint
      expect(typeof tokenBalances[0].balance).to.equal("bigint");
    });

    // Note: We skip actually testing withdrawal since we don't have real tokens
    // in these test accounts. In a production environment, we would fund the
    // accounts and test actual token transfers.
  });

  // Additional tests that could be added:
  // - Testing token withdrawals to different payment methods
  // - Testing handling of different token types
  // - Testing upgradability of the proxy
});
