import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import "package:pointycastle/export.dart";

/// Helper class to handle RSA key generation and encoding
class RsaKeyHelper {
  Future<AsymmetricKeyPair<PublicKey, PrivateKey>> computeRSAKeyPair(
      SecureRandom secureRandom) {
    return compute(getRsaKeyPair, secureRandom);
  }

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
    print('in RSA key pair');

    var rsapars =
        RSAKeyGeneratorParameters(BigInt.from(65537), 512, 5); // the man put 5
    var params = ParametersWithRandom(rsapars, secureRandom);

    var keyGenerator = RSAKeyGenerator();
    keyGenerator.init(params);
    print("generating next");
    final pair = keyGenerator.generateKeyPair();

    var myPublic = pair.publicKey as RSAPublicKey;
    var myPrivate = pair.privateKey as RSAPrivateKey;
    print(myPublic.modulus);
    print((myPublic.modulus)?.toRadixString(16));
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }
}
