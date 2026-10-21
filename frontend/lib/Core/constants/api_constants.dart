import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Yerel ağdaki bilgisayarının IPv4 adresi
  static const String _localIp = '192.168.1.2';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    if (Platform.isAndroid || Platform.isIOS) {
      // Gerçek fiziksel telefon yerel ağ adresi üzerinden bilgisayara bağlanır
      return 'http://$_localIp:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static String get feedEndpoint => '$baseUrl/api/v1/feed';
  static String get duyurularEndpoint => '$baseUrl/api/v1/duyurular';
  static String get haberlerEndpoint => '$baseUrl/api/v1/haberler';
  static String get akademisyenlerEndpoint => '$baseUrl/api/v1/akademisyenler';
}
