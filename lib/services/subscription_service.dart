import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  // ✅ ÚNICA KEY de verdad para premium — PartidaService también la usa
  static const String keyIsPremium =
      'isPremium'; // ← public para acceso externo
  static const String _keyExpiresAt = 'expiresAt';

  static const String _revenueCatApiKeyAndroid =
      'test_VtFgCxgeOicvUcTMTCbKKjxLjQb';
  static const String _revenueCatApiKeyIos = 'YOUR_IOS_KEY_AQUI';

  static const String kProductId = 'domino_premium_monthly';

  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ─────────────────────────────────────────
  // INICIALIZACIÓN — llama en main.dart
  // ─────────────────────────────────────────

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    final uid = FirebaseAuth.instance.currentUser?.uid;

    final bool isIos =
        Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS;
    final String apiKey = isIos
        ? _revenueCatApiKeyIos
        : _revenueCatApiKeyAndroid;

    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);

    if (uid != null) {
      await Purchases.logIn(uid);
    }
  }

  // ─────────────────────────────────────────
  // VERIFICAR PREMIUM
  // ─────────────────────────────────────────

  Future<bool> isPremium() async {
     return true;
    // 1️⃣ Leer cache local primero (funciona sin internet)
    final bool cached = await _isPremiumDesdeCache();

    try {
      // 2️⃣ Intentar validar con RevenueCat
      final CustomerInfo info = await Purchases.getCustomerInfo().timeout(
        const Duration(seconds: 5),
      ); // ✅ timeout para no colgar la UI

      final bool active = info.entitlements.active.containsKey('premium');

      // ✅ Siempre actualizar cache con el valor real
      await _guardarCacheLocal(active, info);
      await _sincronizarFirestore(active, info);

      return active;
    } catch (_) {
      // 3️⃣ Sin internet → usar cache guardado
      return cached;
    }
  }

  // ─────────────────────────────────────────
  // COMPRAR SUSCRIPCIÓN
  // ─────────────────────────────────────────

  Future<PurchaseResult> comprar() async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      final Package? package = offerings.current?.monthly;

      if (package == null) {
        return PurchaseResult.error(
          'No se encontró el producto. Intenta más tarde.',
        );
      }

      final CustomerInfo info = await Purchases.purchasePackage(package);
      final bool active = info.entitlements.active.containsKey('premium');

      if (active) {
        await _guardarCacheLocal(active, info);
        await _sincronizarFirestore(active, info);
        return PurchaseResult.success();
      }

      return PurchaseResult.error('La compra no se completó.');
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled();
      }
      return PurchaseResult.error('Error al procesar el pago: ${e.name}');
    } catch (e) {
      return PurchaseResult.error('Error inesperado: $e');
    }
  }

  // ─────────────────────────────────────────
  // RESTAURAR COMPRA
  // ─────────────────────────────────────────

  Future<PurchaseResult> restaurar() async {
    try {
      final CustomerInfo info = await Purchases.restorePurchases();
      final bool active = info.entitlements.active.containsKey('premium');
      await _guardarCacheLocal(active, info);
      await _sincronizarFirestore(active, info);
      if (active) return PurchaseResult.success();
      return PurchaseResult.error('No se encontraron compras anteriores.');
    } catch (e) {
      return PurchaseResult.error('Error al restaurar: $e');
    }
  }

  // ─────────────────────────────────────────
  // OBTENER PRECIO
  // ─────────────────────────────────────────

  Future<String> getPrecio() async {
    try {
      final Offerings offerings = await Purchases.getOfferings();
      final Package? package = offerings.current?.monthly;
      return package?.storeProduct.priceString ?? '\$0.99';
    } catch (_) {
      return '\$0.99';
    }
  }

  // ─────────────────────────────────────────
  // CACHE LOCAL — fuente de verdad offline
  // ─────────────────────────────────────────

  Future<void> _guardarCacheLocal(
    bool isPremiumValue,
    CustomerInfo info,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    // ✅ Guarda con keyIsPremium (public) para que PartidaService lo lea
    await prefs.setBool(keyIsPremium, isPremiumValue);

    final String? expiration =
        info.entitlements.active['premium']?.expirationDate;
    if (expiration != null) {
      await prefs.setString(_keyExpiresAt, expiration);
    } else if (!isPremiumValue) {
      // ✅ Si ya no es premium, limpiar fecha de expiración
      await prefs.remove(_keyExpiresAt);
    }
  }

  Future<bool> _isPremiumDesdeCache() async {
    final prefs = await SharedPreferences.getInstance();
    final bool cached = prefs.getBool(keyIsPremium) ?? false;
    if (!cached) return false;

    final String? expiresAtStr = prefs.getString(_keyExpiresAt);
    if (expiresAtStr == null) return cached; // sin fecha → asumir válido

    final DateTime? expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null) return cached;

    // ✅ Si expiró, limpiar cache automáticamente
    if (DateTime.now().isAfter(expiresAt)) {
      await prefs.setBool(keyIsPremium, false);
      await prefs.remove(_keyExpiresAt);
      return false;
    }

    return true;
  }

  // ─────────────────────────────────────────
  // FIRESTORE — solo 1 doc por usuario
  // ─────────────────────────────────────────

  Future<void> _sincronizarFirestore(
    bool isPremiumValue,
    CustomerInfo info,
  ) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final String? expiration =
          info.entitlements.active['premium']?.expirationDate;
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'isPremium': isPremiumValue,
        'expiresAt': expiration ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // No crítico — cache local es suficiente
    }
  }
}

// ══════════════════════════════════════════════════════════════
// PurchaseResult
// ══════════════════════════════════════════════════════════════

enum PurchaseStatus { success, cancelled, error }

class PurchaseResult {
  final PurchaseStatus status;
  final String? message;

  PurchaseResult._({required this.status, this.message});

  factory PurchaseResult.success() =>
      PurchaseResult._(status: PurchaseStatus.success);
  factory PurchaseResult.cancelled() =>
      PurchaseResult._(status: PurchaseStatus.cancelled);
  factory PurchaseResult.error(String message) =>
      PurchaseResult._(status: PurchaseStatus.error, message: message);

  bool get isSuccess => status == PurchaseStatus.success;
  bool get isCancelled => status == PurchaseStatus.cancelled;
  bool get isError => status == PurchaseStatus.error;
}
