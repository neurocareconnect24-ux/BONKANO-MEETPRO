/// SECURITY FIX P0-2: Stockage sécurisé pour les données sensibles
///
/// Utilise flutter_secure_storage au lieu de GetStorage/SharedPreferences
/// pour stocker les mots de passe et tokens.
/// - Android: EncryptedSharedPreferences (AES-256)
/// - iOS: Keychain
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Clés de stockage sécurisé
  static const _keyPassword = 'SECURE_USER_PASSWORD';
  static const _keyApiToken = 'SECURE_API_TOKEN';

  /// Sauvegarder le mot de passe de manière sécurisée (chiffré)
  static Future<void> savePassword(String password) async {
    await _storage.write(key: _keyPassword, value: password);
  }

  /// Lire le mot de passe stocké de manière sécurisée
  static Future<String?> readPassword() async {
    return await _storage.read(key: _keyPassword);
  }

  /// Supprimer le mot de passe stocké
  static Future<void> deletePassword() async {
    await _storage.delete(key: _keyPassword);
  }

  /// Sauvegarder le token API de manière sécurisée
  static Future<void> saveApiToken(String token) async {
    await _storage.write(key: _keyApiToken, value: token);
  }

  /// Lire le token API stocké
  static Future<String?> readApiToken() async {
    return await _storage.read(key: _keyApiToken);
  }

  /// Supprimer le token API
  static Future<void> deleteApiToken() async {
    await _storage.delete(key: _keyApiToken);
  }

  /// Nettoyer toutes les données sécurisées (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
