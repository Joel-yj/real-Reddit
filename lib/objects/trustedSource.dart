import 'package:pointycastle/asymmetric/api.dart';

class TrustedSource {
  String? id;
  RSAPublicKey? key;
  TrustedSource({
    this.id,
    required this.key,
  });

  factory TrustedSource.fromJson(dynamic json) {
    RSAPublicKey rebuildKey = RSAPublicKey(
        BigInt.parse(json["Modulus"] as String),
        BigInt.parse(json["PublicKey"] as String));
    return TrustedSource(id: json["id"] as String, key: rebuildKey);
  }
}
