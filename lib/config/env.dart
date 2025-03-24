class Env {
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '',
  );
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '',
  );
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '',
  );
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  static bool get isProduction => const bool.fromEnvironment(
        'dart.vm.product',
        defaultValue: false,
      );

  static String get apiUrl => isProduction
      ? 'https://api.chattr.com'
      : 'https://dev-api.chattr.com';

  static String get wsUrl => isProduction
      ? 'wss://ws.chattr.com'
      : 'wss://dev-ws.chattr.com';
} 