import 'dart:convert';

class CoreJwtDecoder {
  CoreJwtDecoder._();

  static final instance = CoreJwtDecoder._();

  Map<String, dynamic> decodeJWT(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw ArgumentError('Invalid token');
    }

    final payload = _decodeBase64Url(parts[1]);
    final payloadMap = json.decode(payload);

    if (payloadMap is! Map<String, dynamic>) {
      throw ArgumentError('Invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64Url(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
      case 3:
        output += '=';
      default:
        throw ArgumentError('Invalid Base64Url string');
    }

    return utf8.decode(base64Url.decode(output));
  }
}
