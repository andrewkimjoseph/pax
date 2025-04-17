// ABI for TaskManagerV1 contract
export const taskManagerV1ABI = [
    {
      inputs: [
        {
          internalType: "address",
          name: "taskManager",
          type: "address"
        },
        {
          internalType: "uint256",
          name: "_rewardAmountPerParticipantProxyInWei",
          type: "uint256"
        },
        {
          internalType: "uint256",
          name: "_targetNumberOfParticipantProxies",
          type: "uint256"
        },
        {
          internalType: "address",
          name: "_rewardToken",
          type: "address"
        }
      ],
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
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "bytes",
          name: "signature",
          type: "bytes"
        },
        {
          indexed: false,
          internalType: "address",
          name: "participantProxy",
          type: "address"
        }
      ],
      name: "ClaimingSignatureUsed",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "taskManager",
          type: "address"
        },
        {
          indexed: false,
          internalType: "contract IERC20Metadata",
          name: "tokenAddress",
          type: "address"
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "rewardAmount",
          type: "uint256"
        }
      ],
      name: "GivenTokenWithdrawn",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "participantProxy",
          type: "address"
        },
        {
          indexed: false,
          internalType: "address",
          name: "paxAccountContractAddress",
          type: "address"
        }
      ],
      name: "ParticipantProxyMarkedAsRewarded",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "participantProxy",
          type: "address"
        }
      ],
      name: "ParticipantProxyScreened",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "sender",
          type: "address"
        }
      ],
      name: "Paused",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "paxAccountContractAddress",
          type: "address"
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "rewardAmount",
          type: "uint256"
        }
      ],
      name: "PaxAccountRewarded",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "uint256",
          name: "oldRewardTokenRewardAmountPerParticipantProxyInWei",
          type: "uint256"
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "newRewardTokenRewardAmountPerParticipantProxyInWei",
          type: "uint256"
        }
      ],
      name: "RewardAmountUpdated",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "taskManager",
          type: "address"
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "rewardAmount",
          type: "uint256"
        }
      ],
      name: "RewardTokenWithdrawn",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "bytes",
          name: "signature",
          type: "bytes"
        },
        {
          indexed: false,
          internalType: "address",
          name: "participantProxy",
          type: "address"
        }
      ],
      name: "ScreeningSignatureUsed",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "taskManager",
          type: "address"
        }
      ],
      name: "TaskManagerCreated",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "uint256",
          name: "oldTargetNumberOfParticipantProxies",
          type: "uint256"
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "newTargetNumberOfParticipantProxies",
          type: "uint256"
        }
      ],
      name: "TargetNumberOfParticipantProxiesUpdated",
      type: "event"
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: false,
          internalType: "address",
          name: "sender",
          type: "address"
        }
      ],
      name: "Unpaused",
      type: "event"
    },
    {
      inputs: [
        {
          internalType: "bytes",
          name: "signature",
          type: "bytes"
        }
      ],
      name: "checkIfClaimingSignatureIsUsed",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [],
      name: "checkIfContractIsPaused",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "participantProxy",
          type: "address"
        }
      ],
      name: "checkIfParticipantProxyIsRewarded",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "participantProxy",
          type: "address"
        }
      ],
      name: "checkIfParticipantProxyIsScreened",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "bytes",
          name: "signature",
          type: "bytes"
        }
      ],
      name: "checkIfScreeningSignatureIsUsed",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [],
      name: "getNumberOfClaimedRewards",
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
      name: "getNumberOfRewardedParticipantProxies",
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
      name: "getNumberOfScreenedParticipantProxies",
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
      name: "getNumberOfUsedClaimingSignatures",
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
      name: "getNumberOfUsedScreeningSignatures",
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
      name: "getOwner",
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
      inputs: [],
      name: "getRewardAmountPerParticipantProxyInWei",
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
      name: "getRewardTokenContractAddress",
      outputs: [
        {
          internalType: "contract IERC20Metadata",
          name: "",
          type: "address"
        }
      ],
      stateMutability: "view",
      type: "function"
    },
    {
      inputs: [],
      name: "getRewardTokenContractBalanceAmount",
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
      name: "getTargetNumberOfParticipantProxies",
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
      inputs: [],
      name: "pausetask",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "participantProxy",
          type: "address"
        },
        {
          internalType: "address",
          name: "paxAccountContractAddress",
          type: "address"
        },
        {
          internalType: "string",
          name: "rewardId",
          type: "string"
        },
        {
          internalType: "uint256",
          name: "nonce",
          type: "uint256"
        },
        {
          internalType: "bytes",
          name: "signature",
          type: "bytes"
        }
      ],
      name: "processRewardClaimByParticipantProxy",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "participantProxy",
          type: "address"
        },
        {
          internalType: "string",
          name: "taskId",
          type: "string"
        },
        {
          internalType: "uint256",
          name: "nonce",
          type: "uint256"
        },
        {
          internalType: "bytes",
          name: "signature",
          type: "bytes"
        }
      ],
      name: "screenParticipantProxy",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [],
      name: "unpausetask",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_newRewardAmountPerParticipantProxyInWei",
          type: "uint256"
        }
      ],
      name: "updateRewardAmountPerParticipantProxy",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "uint256",
          name: "_newTargetNumberOfParticipantProxies",
          type: "uint256"
        }
      ],
      name: "updateTargetNumberOfParticipantProxies",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [
        {
          internalType: "contract IERC20Metadata",
          name: "token",
          type: "address"
        }
      ],
      name: "withdrawAllGivenTokenTotaskManager",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    },
    {
      inputs: [],
      name: "withdrawAllRewardTokenToTaskManager",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function"
    }
  ];