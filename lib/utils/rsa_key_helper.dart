import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import "package:pointycastle/export.dart";

/// Helper class to handle RSA key generation and encoding
class RsaKeyHelper {
  /// Generates a [SecureRandom]
  /// Returns [FortunaRandom] to be used in the [AsymmetricKeyPair] generation
  SecureRandom getSecureRandom() {
    var secureRandom = FortunaRandom();
    var random = Random.secure();
    List<int> seeds = [];
    for (int i = 0; i < 32; i++) {
      seeds.add(random.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));
    return secureRandom;
  }

  /// Generate a [PublicKey] and [PrivateKey] pair
  /// Returns a [AsymmetricKeyPair] based on the [RSAKeyGenerator] with custom parameters,
  /// including a [SecureRandom]
  AsymmetricKeyPair<PublicKey, PrivateKey> getRsaKeyPair(
      SecureRandom secureRandom) {
    // print('in RSA key pair');

    var rsapars =
        RSAKeyGeneratorParameters(BigInt.from(65537), 512, 5); // the man put 5
    var params = ParametersWithRandom(rsapars, secureRandom);

    var keyGenerator = RSAKeyGenerator();
    keyGenerator.init(params);

    final pair = keyGenerator.generateKeyPair();

    var myPublic = pair.publicKey as RSAPublicKey;
    var myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  //------------------ RSA SIGNING --------------------

  // Creates a [Uint8List] from a string to be signed
  Uint8List createUint8ListFromString(String s) {
    var codec = const Utf8Codec(allowMalformed: true);
    return Uint8List.fromList(codec.encode(s));
  }

  // Sign plaintext by encrypting with Private key
  Uint8List rsaSign(RSAPrivateKey privateKey, String plainText) {
    //final signer = Signer('SHA-256/RSA'); // Get using registry
    var signer = RSASigner(SHA256Digest(), '0609608648016503040201');

    // initialize with true, which means sign
    signer.init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

    final sig = signer.generateSignature(createUint8ListFromString(plainText));

    // TODO: change the list of bytes to _____
    return sig.bytes;
  }

  // Check signature by decrypting with Public key
  bool rsaVerify(
      RSAPublicKey publicKey, String plainText, Uint8List signature) {
    //final signer = Signer('SHA-256/RSA'); // Get using registry
    final sig = RSASignature(signature);

    final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');

    // initialize with false, which means verify
    verifier.init(false, PublicKeyParameter<RSAPublicKey>(publicKey));

    try {
      return verifier.verifySignature(
          createUint8ListFromString(plainText), sig);
    } on ArgumentError {
      return false; // for Pointy Castle 1.0.2 when signature has been modified
    }
  }

  //------------------ End of Signing --------------------
}
