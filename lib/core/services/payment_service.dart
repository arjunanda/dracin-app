import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final _purchaseController = StreamController<PurchaseDetails>.broadcast();
  Stream<PurchaseDetails> get purchaseStream => _purchaseController.stream;

  Future<void> initialize() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('In-app purchases not available');
      return;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      },
      onDone: () {
        _subscription?.cancel();
      },
      onError: (Object error) {
        debugPrint('Purchase stream error: $error');
      },
    );
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Verify purchase if needed
          _purchaseController.add(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> buyPremium() async {
    const Set<String> _kIds = <String>{'premium_access_80k'};

    try {
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(_kIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Product not found: ${response.notFoundIDs}');
      }

      if (response.productDetails.isNotEmpty) {
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: response.productDetails.first,
        );
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        debugPrint(
          'No products available for purchase. Using Mock for Sandbox Testing.',
        );
        // Jika di debug mode, kita aktifkan simulasi sandbox
        if (kDebugMode) {
          await buyMockPremium();
        }
      }
    } catch (e) {
      debugPrint('Error buying premium: $e');
      if (kDebugMode) await buyMockPremium();
    }
  }

  // Fungsi untuk simulasi Sandbox/Testing tanpa Google Play asli
  Future<void> buyMockPremium() async {
    debugPrint('SANDBOX: Memulai simulasi pembelian...');
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('SANDBOX: Pembelian Berhasil (Mock)');
    // Kita biarkan PremiumUpgradeDialog menangani status UI-nya
  }

  void dispose() {
    _subscription?.cancel();
    _purchaseController.close();
  }
}
