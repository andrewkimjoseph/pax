// import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
// import { taskManagerConstructorArgs } from "../../taskManagerConstructorArgs";

// const RESEARCHER_WALLET_ADDRESS = taskManagerConstructorArgs[0];
// const _REWARD_AMOUNT_PER_PARTICIPANT_IN_WEI = taskManagerConstructorArgs[1];
// const _TARGET_NUMBER_OF_PARTICIPANTS = taskManagerConstructorArgs[2];
// const _REWARDTOKEN = taskManagerConstructorArgs[3];


// const TaskManagerV1Module = buildModule("TaskManagerV1Module", (imb) => {
//   const researcher = imb.getParameter(
//     "researcher",
//     RESEARCHER_WALLET_ADDRESS
//   );

//   const _rewardAmountPerParticipantInWei = imb.getParameter(
//     "_rewardAmountPerParticipantInWei",
//     String(_REWARD_AMOUNT_PER_PARTICIPANT_IN_WEI)
//   );

//   const _targetNumberOfParticipants = imb.getParameter(
//     "_targetNumberOfParticipants",
//     String(_TARGET_NUMBER_OF_PARTICIPANTS)
//   );

//   const _rewardToken = imb.getParameter(
//     "_rewardToken",
//     _REWARDTOKEN
//   );

//   const closedSurveyV6 = imb.contract("contracts/TaskManagerV1Module.sol:TaskManagerV1", [
//     researcher,
//     _rewardAmountPerParticipantInWei,
//     _targetNumberOfParticipants,
//     _rewardToken
//   ]);

//   return { closedSurveyV6 };
// });

// export default TaskManagerV1Module;