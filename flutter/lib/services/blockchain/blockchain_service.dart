// services/blockchain_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pax/env/env.dart';
import 'package:pax/models/local/token_info_model.dart';
import 'package:pax/utils/currency_symbol.dart';

class BlockchainService {
  // API key should ideally be stored in a secure configuration
  static final String _apiKey =
      Env.drpcAPIKey; // Replace with your actual API key
  static final String _apiUrl = 'https://lb.drpc.org/ogrpc?network=celo&dkey=';

  // Token configurations
  static final Map<int, TokenInfo> supportedTokens = {
    1: TokenInfo(
      id: 1,
      address: "0x62B8B11039FcfE5aB0C56E502b1C372A3d2a9c7A",
      decimals: 18,
      name: "good_dollar",
      symbol: CurrencySymbolUtil.getSymbolForCurrency('good_dollar'),
    ),
    2: TokenInfo(
      id: 2,
      address: "0x765DE816845861e75A25fCA122bb6898B8B1282a",
      decimals: 18,
      name: "celo_dollar",
      symbol: CurrencySymbolUtil.getSymbolForCurrency('celo_dollar'),
    ),
    3: TokenInfo(
      id: 3,
      address: "0x48065fbBE25f71C9282ddf5e1cD6D6A887483D5e",
      decimals: 6,
      name: "tether_usd",
      symbol: CurrencySymbolUtil.getSymbolForCurrency('tether_usd'),
    ),
    4: TokenInfo(
      id: 4,
      address: "0xcebA9300f2b948710d2653dD7B07f33A8B32118C",
      decimals: 6,
      name: "usd_coin",
      symbol: CurrencySymbolUtil.getSymbolForCurrency('usd_coin'),
    ),
  };

  // Get the full API URL with key
  static String get _fullApiUrl => '$_apiUrl$_apiKey';

  // Fetch balance for a single token
  static Future<double> fetchTokenBalance(
    String walletAddress,
    int tokenId,
  ) async {
    if (!supportedTokens.containsKey(tokenId)) {
      throw Exception("Unsupported token ID: $tokenId");
    }

    final tokenInfo = supportedTokens[tokenId]!;
    return await _getTokenBalance(
      walletAddress,
      tokenInfo.address,
      tokenInfo.decimals,
    );
  }

  // Fetch balances for all supported tokens
  static Future<Map<int, double>> fetchAllTokenBalances(
    String walletAddress,
  ) async {
    final Map<int, double> balances = {};

    for (final entry in supportedTokens.entries) {
      try {
        final balance = await _getTokenBalance(
          walletAddress,
          entry.value.address,
          entry.value.decimals,
        );
        balances[entry.key] = balance;
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching ${entry.value.name} balance: $e');
        }
        balances[entry.key] = 0.0;
      }
    }

    return balances;
  }

  // Helper method to get token balance using RPC call
  static Future<double> _getTokenBalance(
    String walletAddress,
    String tokenAddress,
    int decimals,
  ) async {
    // Format wallet address (remove prefix and pad)
    var addressWithoutPrefix =
        walletAddress.startsWith('0x')
            ? walletAddress.substring(2)
            : walletAddress;
    var paddedAddress = addressWithoutPrefix.padLeft(64, '0');

    // Construct the data payload (balanceOf function)
    var data = "0x70a08231$paddedAddress";

    var requestBody = jsonEncode({
      "method": "eth_call",
      "params": [
        {"to": tokenAddress, "data": data},
        "latest",
      ],
      "id": "1",
      "jsonrpc": "2.0",
    });

    // Set headers
    var headers = {'Content-Type': 'application/json'};

    // Make the RPC call
    final response = await http.post(
      Uri.parse(_fullApiUrl),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);

      if (responseData.containsKey('result')) {
        var balanceHex = responseData['result'];

        // Handle the case where result is just "0x"
        BigInt balanceBigInt;
        if (balanceHex == "0x" || balanceHex == "0x0") {
          balanceBigInt = BigInt.zero;
        } else {
          balanceBigInt = BigInt.parse(balanceHex.substring(2), radix: 16);
        }

        // Convert to decimal with appropriate decimals
        var divisor = BigInt.from(10).pow(decimals);
        var balance = (balanceBigInt.toDouble() / divisor.toDouble());

        return balance;
      } else if (responseData.containsKey('error')) {
        throw Exception("RPC Error: ${responseData['error']}");
      }
    }

    throw Exception(
      "Failed to get token balance. Status code: ${response.statusCode}",
    );
  }

  // Format balance for display
  static String formatBalance(double balance, int tokenId) {
    if (!supportedTokens.containsKey(tokenId)) {
      return "$balance";
    }

    final symbol = supportedTokens[tokenId]!.name;

    // Format with 4 decimal places for larger amounts, more precision for smaller amounts
    if (balance >= 1) {
      return "$symbol ${balance.toStringAsFixed(4)}";
    } else if (balance >= 0.0001) {
      return "$symbol ${balance.toStringAsFixed(6)}";
    } else {
      return "$symbol ${balance.toStringAsFixed(8)}";
    }
  }

  // Check if contract has sufficient balance for withdrawal
  static Future<bool> hasSufficientBalance(
    String contractOrEOAAddress,
    String currencyAddress,
    double amountToWithdraw,
    int decimals,
  ) async {
    try {
      final balance = await _getTokenBalance(
        contractOrEOAAddress,
        currencyAddress,
        decimals,
      );

      if (kDebugMode) {
        print(
          'Contract/EOA balance: $balance, Amount to withdraw: $amountToWithdraw',
        );
      }

      return balance >= amountToWithdraw;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking contract balance: $e');
      }
      return false;
    }
  }
}
