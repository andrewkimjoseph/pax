import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pax/env/env.dart';

final clarityConfigProvider = Provider<ClarityConfig>((ref) {
  return ClarityConfig(projectId: Env.clarityProjectId);
});
