import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart' as pc;

class RSACryptoService {
  /// Encrypts a plaintext string (e.g. JSON {"username": "...", "password": "..."})
  /// using the server's RSA 2048-bit Public Key in PKCS8/X.509 PEM format.
  static String encryptPayload(String plaintext, String publicKeyPem) {
    final parser = RSAKeyParser();
    final pc.RSAPublicKey publicKey = parser.parse(publicKeyPem) as pc.RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1));
    final encrypted = encrypter.encrypt(plaintext);
    return encrypted.base64;
  }
}

