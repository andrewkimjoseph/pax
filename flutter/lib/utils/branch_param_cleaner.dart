import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:pax/utils/regex.dart';

/// Utility class for cleaning Branch SDK parameters
class BranchParamCleaner {
  /// Cleans a single parameter key by removing special characters
  static String cleanKey(String key) {
    return key.replaceAll(branchParamCleaner, '');
  }

  /// Cleans all keys in a Branch parameters map
  static Map<String, dynamic> cleanParams(Map<dynamic, dynamic> params) {
    Map<String, dynamic> cleanedParams = {};

    params.forEach((key, value) {
      String cleanedKey = cleanKey(key.toString());
      cleanedParams[cleanedKey] = value;
    });

    return cleanedParams;
  }

  /// Gets and cleans Branch referring parameters
  static Future<Map<String, dynamic>> getCleanedReferringParams() async {
    Map<dynamic, dynamic> params =
        await FlutterBranchSdk.getFirstReferringParams();
    return cleanParams(params);
  }

  /// Merges cleaned Branch first referring parameters with provided properties
  static Future<Map<String, dynamic>> mergeWithBranchFirstReferringParams(
    Map<String, dynamic>? properties,
  ) async {
    Map<dynamic, dynamic> params =
        await FlutterBranchSdk.getFirstReferringParams();
    Map<String, dynamic> eventProperties = properties ?? {};

    if (params.isNotEmpty) {
      Map<String, dynamic> cleanedParams = cleanParams(params);
      eventProperties.addAll(cleanedParams);
    }

    return eventProperties;
  }
}
