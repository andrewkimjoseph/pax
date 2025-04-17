// ABI for PaxAccountV1 contract
export const paxAccountV1ABI = [
    {
      inputs: [],
      stateMutability: "nonpayable",
      type: "constructor"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "owner",
          type: "address"
        }
      ],
      name: "OwnableUnauthorizedAccount",
      type: "error"
    },
    {
      inputs: [],
      name: "UUPSUnauthorizedCallContext",
      type: "error"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "paxAccount",
          type: "address"
        }
      ],
      name: "PaxAccountCreated",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "uint256",
          name: "paymentMethodId",
          type: "uint256"
        },
        {
          indexed: false,
          internalType: "address",
          name: "paymentMethod",
          type: "address"
        }
      ],
      name: "PaymentMethodAdded",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "paymentMethod",
          type: "address"
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "amountRequested",
          type: "uint256"
        },
        {
          indexed: false,
          internalType: "bytes32",
          name: "currencySymbol",
          type: "bytes32"
        }
      ],
      name: "TokenWithdrawn",
      type: "event"
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "paymentMethodId",
          type: "uint256"
        },
        {
          internalType: "address",
          name: "paymentMethod",
          type: "address"
        }
      ],
      name: "addNonPrimaryPaymentMethod",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "paymentMethodId",
          type: "uint256"
        },
        {
          internalType: "address",
          name: "paymentMethod",
          type: "address"
        }
      ],
      name: "addPaymentMethod",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [],
      name: "getPaymentMethods",
      outputs: [
        {
          components: [
            {
              internalType: "uint256",
              name: "id",
              type: "uint256"
            },
            {
              internalType: "address",
              name: "paymentAddress",
              type: "address"
            }
          ],
          internalType: "struct PaxAccountV1.PaymentMethod[]",
          name: "",
          type: "tuple[]"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [],
      name: "getPrimaryPaymentMethod",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "contract ERC20Upgradeable[]",
          name: "tokens",
          type: "address[]"
        }
      ],
      name: "getTokenBalances",
      outputs: [
        {
          components: [
            {
              internalType: "address",
              name: "tokenAddress",
              type: "address"
            },
            {
              internalType: "uint256",
              name: "balance",
              type: "uint256"
            }
          ],
          internalType: "struct PaxAccountV1.TokenBalance[]",
          name: "",
          type: "tuple[]"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address"
        }
      ],
      name: "historicalTokenWithdrawalAmounts",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_owner",
          type: "address"
        },
        {
          internalType: "address",
          name: "_primaryPaymentMethod",
          type: "address"
        }
      ],
      name: "initialize",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [],
      name: "numberOfPaymentMethods",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [],
      name: "owner",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32"
        }
      ],
      name: "paymentMethods",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "paymentMethodId",
          type: "uint256"
        },
        {
          internalType: "uint256",
          name: "amountRequested",
          type: "uint256"
        },
        {
          internalType: "contract ERC20Upgradeable",
          name: "currency",
          type: "address"
        }
      ],
      name: "withdrawToPaymentMethod",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    }
  ];