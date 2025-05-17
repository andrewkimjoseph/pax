enum WithdrawState { initial, submitting, success, error }

class WithdrawStateModel {
  final WithdrawState state;
  final String? errorMessage;
  final bool isSubmitting;
  final String? txnHash;
  final String? withdrawalId;

  WithdrawStateModel({
    this.state = WithdrawState.initial,
    this.errorMessage,
    this.isSubmitting = false,
    this.txnHash,
    this.withdrawalId,
  });

  WithdrawStateModel copyWith({
    WithdrawState? state,
    String? errorMessage,
    bool? isSubmitting,
    String? txnHash,
    String? withdrawalId,
  }) {
    return WithdrawStateModel(
      state: state ?? this.state,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      txnHash: txnHash ?? this.txnHash,
      withdrawalId: withdrawalId ?? this.withdrawalId,
    );
  }
}
