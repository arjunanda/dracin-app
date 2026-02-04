import 'dart:async';
import 'package:dio/dio.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('In-app purchases (One-Time Purchase) not available');
      return;
    }

    _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        debugPrint('Purchase stream done');
        _purchaseStreamSubscription?.cancel();
      },
      onError: (Object error) {
        debugPrint('Purchase stream error: $error');
      },
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Handle pending status
      } else {
        _purchaseController.add(purchaseDetails);

        if (purchaseDetails.pendingCompletePurchase) {
          // Acknowledge the one-time purchase
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> buyPremium(Dio dio) async {
    const String productId = 'premium_access_80k';
    const Set<String> _kIds = <String>{productId};

    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('Billing system not available');
        return false;
      }

      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_kIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Product not found: ${response.notFoundIDs}');
      }

      if (response.productDetails.isEmpty) {
        debugPrint('No product details found for $productId');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );

      final completer = Completer<bool>();
      StreamSubscription? streamSubscription;

      streamSubscription = purchaseStream.listen((purchase) async {
        if (purchase.productID == productId) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            try {
              final String token =
                  purchase.verificationData.serverVerificationData;
              await verifyPurchase(dio, token, productId);
              debugPrint('DEBUG_PAYMENT: Purchase successful and verified!');
              if (!completer.isCompleted) completer.complete(true);
            } catch (e) {
              debugPrint('Verification failed: $e');
              if (!completer.isCompleted) completer.complete(false);
            }
          } else if (purchase.status == PurchaseStatus.error) {
            debugPrint(
              'DEBUG_PAYMENT: Purchase error: ${purchase.error?.message}',
            );
            if (purchase.error!.message.contains('item_already_owned')) {
              debugPrint('DEBUG_PAYMENT: Item already owned by user!');
              // Optionally handle as success or trigger restore
            }
            if (!completer.isCompleted) completer.complete(false);
          } else if (purchase.status == PurchaseStatus.canceled) {
            debugPrint('DEBUG_PAYMENT: Purchase canceled');
            if (!completer.isCompleted) completer.complete(false);
          }
        }
      });

      final successInitiated = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!successInitiated) {
        await streamSubscription.cancel();
        return false;
      }

      final result = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => false,
      );

      await streamSubscription.cancel();
      return result;
    } catch (e) {
      debugPrint('Error buying premium: $e');
      return false;
    }
  }

  Future<void> verifyPurchase(
    Dio dio,
    String purchaseToken,
    String productId,
  ) async {
    try {
      debugPrint('Verifying one-time purchase: $productId');
      final response = await dio.post(
        'confirm-premium',
        data: {'purchase_token': purchaseToken, 'product_id': productId},
      );
      debugPrint('Purchase verification response: ${response.data}');
    } catch (e) {
      debugPrint('Purchase verification failed: $e');
      rethrow;
    }
  }

  void dispose() {
    _purchaseStreamSubscription?.cancel();
    _purchaseController.close();
  }
}
