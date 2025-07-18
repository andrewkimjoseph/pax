import { Address, getReferralTag } from "@divvi/referral-sdk";
import { PAX_MASTER_PRIVATE_KEY_ACCOUNT } from "../config";
import { SmartAccountClient } from "permissionless";

export function getReferralTagFromSmartAccount(
  smartAccount: SmartAccountClient
): String {
  return getReferralTag({
    user: smartAccount.account?.address as Address,
    consumer: PAX_MASTER_PRIVATE_KEY_ACCOUNT.address,
  });
}
