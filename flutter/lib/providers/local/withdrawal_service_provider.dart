import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/providers/db/pax_account/pax_account_provider.dart';
import 'package:pax/providers/local/activity_provider.dart';
import 'package:pax/services/withdrawal_service.dart';

final withdrawalServiceProvider = Provider<WithdrawalService>((ref) {
  return WithdrawalService(
    paxAccountRepository: ref.watch(paxAccountRepositoryProvider),
    withdrawalRepository: ref.watch(withdrawalRepositoryProvider),
  );
});
