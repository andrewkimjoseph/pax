// Create a new provider to handle balance updates
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/reward_state_provider.dart';
import 'package:pax/providers/local/withdrawal_provider.dart';

final balanceUpdateProvider = Provider.family<void, String?>((
  ref,
  participantId,
) {
  // This will run whenever the rewards stream changes
  ref.watch(rewardsStreamProvider(participantId));

  // This will run whenever the withdrawals stream changes
  ref.watch(withdrawalsStreamProvider(participantId));

  // Schedule the balance sync for the next frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (participantId != null) {
      if (kDebugMode) {
        print("syncing balances from blockchain");
      }
      ref.read(paxAccountProvider.notifier).syncBalancesFromBlockchain();
    }
  });
});
