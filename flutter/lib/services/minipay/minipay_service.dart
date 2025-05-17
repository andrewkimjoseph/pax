// services/minipay/minipay_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pax/env/env.dart';
import 'package:pax/models/firestore/pax_account/pax_account_model.dart';
import 'package:pax/repositories/firestore/pax_account/pax_account_repository.dart';
import 'package:pax/repositories/firestore/payment_method/payment_method_repository.dart';
import 'package:pointycastle/digests/keccak.dart';

class MiniPayService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final PaxAccountRepository _paxAccountRepository;
  final PaymentMethodRepository _paymentMethodRepository;

  // API endpoint for whitelist checking (from whitelist_status.dart)
  final Uri _whitelistApiUrl = Uri.parse(
    'https://lb.drpc.org/ogrpc?network=celo&dkey=${Env.drpcAPIKey}',
  );
  final String _whitelistContractAddress =
      "0xC361A6E67822a0EDc17D899227dd9FC50BD62F42";

  MiniPayService({
    required PaxAccountRepository paxAccountRepository,
    required PaymentMethodRepository paymentMethodRepository,
  }) : _paxAccountRepository = paxAccountRepository,
       _paymentMethodRepository = paymentMethodRepository;

  // Get PaxAccount for user
  Future<PaxAccount?> getPaxAccount(String userId) async {
    return await _paxAccountRepository.getAccount(userId);
  }

  // Update PaxAccount
  Future<PaxAccount> updatePaxAccount(
    String userId,
    Map<String, dynamic> data,
  ) async {
    return await _paxAccountRepository.updateAccount(userId, data);
  }

  // Create payment method
  Future<void> createPaymentMethod({
    required String userId,
    required String paxAccountId,
    required String walletAddress,
  }) async {
    await _paymentMethodRepository.createPaymentMethod(
      participantId: userId,
      paxAccountId: paxAccountId,
      walletAddress: walletAddress,
    );
  }

  // Validate Ethereum address format
  bool isValidEthereumAddress(String address) {
    // Ethereum addresses are 42 characters long (including '0x' prefix)
    // and contain only hexadecimal characters
    final RegExp ethAddressRegex = RegExp(r'^0x[0-9a-fA-F]{40}$');
    return ethAddressRegex.hasMatch(address);
  }

  // Check if wallet address is already used
  Future<bool> isWalletAddressUsed(String walletAddress) async {
    return await _paymentMethodRepository.isWalletAddressUsed(walletAddress);
  }

  // Check if wallet is GoodDollar verified
  Future<bool> isGoodDollarVerified(String walletAddress) async {
    try {
      // Use logic from whitelist_status.dart
      final rootAddress = await _getWhitelistedRoot(walletAddress);

      if (rootAddress == "0x0000000000000000000000000000000000000000") {
        return false; // Not whitelisted
      }

      // Get last authentication timestamp
      final lastAuthTimestamp = await getLastAuthenticated(rootAddress);

      // Get authentication period
      final authPeriod = await _getAuthenticationPeriod();

      // Calculate if verification is still valid
      if (lastAuthTimestamp > 0) {
        final expiryTimestamp =
            lastAuthTimestamp +
            (authPeriod * 24 * 60 * 60); // Convert days to seconds
        final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

        return currentTimestamp <= expiryTimestamp; // Valid if not expired
      }

      return false; // No authentication timestamp found
    } catch (e) {
      if (kDebugMode) {
        print('Error checking GoodDollar verification: $e');
      }
      return false;
    }
  }

  // Call Firebase Function to create server wallet
  Future<Map<String, dynamic>> createServerWallet() async {
    try {
      // Create callable function
      final callable = _functions.httpsCallable(
        'createPrivyServerWallet',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );

      // Call the function
      final result = await callable.call();

      if (result.data == null) {
        throw Exception('Server wallet creation failed - empty response');
      }

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating server wallet: $e');
      }
      rethrow;
    }
  }

  // Call Firebase Function to deploy smart contract
  Future<Map<String, dynamic>> deployPaxAccountV1ProxyContractAddress(
    String primaryPaymentMethod,
    String serverWalletId,
  ) async {
    try {
      // Create callable function
      final callable = _functions.httpsCallable(
        'createPaxAccountV1Proxy',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 300)),
      );

      // Call the function with parameters
      final result = await callable.call({
        '_primaryPaymentMethod': primaryPaymentMethod,
        'serverWalletId': serverWalletId,
      });

      if (result.data == null) {
        throw Exception('Contract deployment failed - empty response');
      }

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error deploying smart contract: $e');
      }
      rethrow;
    }
  }

  // Connect wallet to PaxAccount and create payment method (transaction-like pattern)
  Future<bool> connectWallet({
    required String userId,
    required String walletAddress,
  }) async {
    try {
      // 1. Get PaxAccount
      final paxAccount = await _paxAccountRepository.getAccount(userId);
      if (paxAccount == null) {
        throw Exception('PaxAccount not found');
      }

      // 2. Get or create server wallet - will use existing if available
      Map<String, dynamic> serverWalletData;
      if (paxAccount.serverWalletId != null &&
          paxAccount.serverWalletId!.isNotEmpty &&
          paxAccount.serverWalletAddress != null &&
          paxAccount.serverWalletAddress!.isNotEmpty &&
          paxAccount.smartAccountWalletAddress != null &&
          paxAccount.smartAccountWalletAddress!.isNotEmpty) {
        // Use existing server wallet
        serverWalletData = {
          'serverWalletId': paxAccount.serverWalletId,
          'serverWalletAddress': paxAccount.serverWalletAddress,
          'safeSmartAccountWalletAddress': paxAccount.smartAccountWalletAddress,
        };
      } else {
        // Create a new server wallet
        serverWalletData = await createServerWallet();

        // Update PaxAccount with server wallet data immediately
        // This is critical to prevent creating duplicate server wallets if later steps fail
        await _paxAccountRepository.updateAccount(userId, {
          'serverWalletId': serverWalletData['serverWalletId'],
          'serverWalletAddress': serverWalletData['serverWalletAddress'],
          'safeSmartAccountWalletAddress':
              serverWalletData['safeSmartAccountWalletAddress'],
        });
      }

      // 3. Get or deploy contract
      Map<String, dynamic> contractData;
      if (paxAccount.contractAddress != null &&
          paxAccount.contractAddress!.isNotEmpty &&
          paxAccount.contractCreationTxnHash != null &&
          paxAccount.contractCreationTxnHash!.isNotEmpty) {
        // Use existing contract
        contractData = {
          'contractAddress': paxAccount.contractAddress,
          'contractCreationTxnHash': paxAccount.contractCreationTxnHash,
        };
      } else {
        // Deploy a new contract
        contractData = await deployPaxAccountV1ProxyContractAddress(
          walletAddress,
          serverWalletData['serverWalletId'],
        );

        // Update PaxAccount with contract data immediately
        await _paxAccountRepository.updateAccount(userId, {
          'contractAddress': contractData['contractAddress'],
          'contractCreationTxnHash':
              contractData['contractCreationTxnHash'] ??
              contractData['txnHash'],
        });
      }

      // 4. Create payment method
      await _paymentMethodRepository.createPaymentMethod(
        participantId: userId,
        paxAccountId: paxAccount.id,
        walletAddress: walletAddress,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting wallet: $e');
      }
      return false;
    }
  }

  // Rest of the service methods remain the same...
  // Helper method to get the root whitelisted address (from whitelist_status.dart)
  Future<String> _getWhitelistedRoot(String walletAddress) async {
    // Function signature for getWhitelistedRoot(address)
    var functionSignature = "getWhitelistedRoot(address)";
    var functionSelector = _bytesToHex(
      _keccak256(ascii.encode(functionSignature)),
    ).substring(0, 8);

    // Remove 0x prefix if present and pad address
    var addressWithoutPrefix =
        walletAddress.startsWith('0x')
            ? walletAddress.substring(2)
            : walletAddress;
    var paddedAddress = addressWithoutPrefix.padLeft(64, '0');

    // Construct the data payload
    var data = "0x$functionSelector$paddedAddress";

    var result = await _makeEthCall(_whitelistContractAddress, data);
    return _parseAddressResult(result);
  }

  // New method to add to the MiniPayService class

  // Get GoodDollar identity expiry date as a Timestamp
  Future<Timestamp?> getGoodDollarIdentityExpiryDate(
    String walletAddress,
  ) async {
    try {
      // Get the root whitelisted address
      final rootAddress = await _getWhitelistedRoot(walletAddress);

      if (rootAddress == "0x0000000000000000000000000000000000000000") {
        return null; // Not whitelisted
      }

      // Get last authentication timestamp
      final lastAuthTimestamp = await getLastAuthenticated(rootAddress);

      // Get authentication period
      final authPeriod = await _getAuthenticationPeriod();

      // Calculate expiry timestamp if authenticated
      if (lastAuthTimestamp > 0) {
        // Convert days to seconds and add to last authentication time
        final expiryTimestamp = lastAuthTimestamp + (authPeriod * 24 * 60 * 60);

        // Convert Unix timestamp (seconds) to Firestore Timestamp
        return Timestamp.fromMillisecondsSinceEpoch(expiryTimestamp * 1000);
      }

      return null; // No authentication timestamp found
    } catch (e) {
      if (kDebugMode) {
        print('Error getting GoodDollar identity expiry date: $e');
      }
      return null;
    }
  }

  // Helper method to get last authenticated timestamp (from whitelist_status.dart)
  Future<int> getLastAuthenticated(String address) async {
    // Function signature for lastAuthenticated(address)
    var functionSignature = "lastAuthenticated(address)";
    var functionSelector = _bytesToHex(
      _keccak256(ascii.encode(functionSignature)),
    ).substring(0, 8);

    // Remove 0x prefix if present and pad address
    var addressWithoutPrefix =
        address.startsWith('0x') ? address.substring(2) : address;
    var paddedAddress = addressWithoutPrefix.padLeft(64, '0');

    // Construct the data payload
    var data = "0x$functionSelector$paddedAddress";

    var result = await _makeEthCall(_whitelistContractAddress, data);
    return _parseIntResult(result);
  }

  // Helper method to get authentication period (from whitelist_status.dart)
  Future<int> _getAuthenticationPeriod() async {
    // Function signature for authenticationPeriod()
    var functionSignature = "authenticationPeriod()";
    var functionSelector = _bytesToHex(
      _keccak256(ascii.encode(functionSignature)),
    ).substring(0, 8);

    // Construct the data payload
    var data = "0x$functionSelector";

    var result = await _makeEthCall(_whitelistContractAddress, data);
    return _parseIntResult(result);
  }

  // Helper method to make Ethereum calls (from whitelist_status.dart)
  Future<String> _makeEthCall(String contractAddress, String data) async {
    var requestBody = jsonEncode({
      "method": "eth_call",
      "params": [
        {"to": contractAddress, "data": data},
        "latest",
      ],
      "id": "1",
      "jsonrpc": "2.0",
    });

    var headers = {'Content-Type': 'application/json'};

    var response = await http.post(
      _whitelistApiUrl,
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData.containsKey('result')) {
        return responseData['result'];
      }
    }

    throw Exception(
      'Failed to call contract: ${response.statusCode} ${response.body}',
    );
  }

  // Utility methods from whitelist_status.dart
  List<int> _keccak256(List<int> input) {
    var keccakDigest = KeccakDigest(256);
    return keccakDigest.process(Uint8List.fromList(input));
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  String _parseAddressResult(String hexResult) {
    if (hexResult == "0x" || hexResult == "0x0") {
      return "0x0000000000000000000000000000000000000000";
    }

    // The address is in the last 20 bytes of the result
    var addressHex = "0x${hexResult.substring(hexResult.length - 40)}";
    return addressHex;
  }

  int _parseIntResult(String hexResult) {
    if (hexResult == "0x" || hexResult == "0x0") {
      return 0;
    }

    return int.parse(hexResult.substring(2), radix: 16);
  }
}
