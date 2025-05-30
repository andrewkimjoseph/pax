import 'package:flutter/foundation.dart';

@immutable
class MaintenanceConfig {
  final bool isUnderMaintenance;
  final String message;

  const MaintenanceConfig({
    required this.isUnderMaintenance,
    required this.message,
  });

  factory MaintenanceConfig.fromJson(Map<String, dynamic> json) {
    return MaintenanceConfig(
      isUnderMaintenance: json['is_under_maintenance'] as bool,
      message: json['maintenance_message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_under_maintenance': isUnderMaintenance,
      'maintenance_message': message,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaintenanceConfig &&
        other.isUnderMaintenance == isUnderMaintenance &&
        other.message == message;
  }

  @override
  int get hashCode {
    return Object.hash(isUnderMaintenance, message);
  }
}
