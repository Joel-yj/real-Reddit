import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CertificateTemplate {
  late String receivedBy;
  late String issueBy;
  late String message;
  // String publicKey;
  late RSAPublicKey key;

  var rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;

  // Constructor
  CertificateTemplate(this.receivedBy, this.issueBy, this.message, this.key);

  CertificateTemplate.empty();

  void issue() {
    var userCert = request();
    signing();
    updateCertBase();
  }

  void verification(event) {}

  void request() {
    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var alicePubKey = res.publicKey as RSAPublicKey;
    var alicePriKey = res.privateKey as RSAPrivateKey;

    // put receiveby(alice)
    // public key into the cert template

    // update firebase alice
    db.collection("Users").doc("Alice").set(
        {"PrivateKey": alicePriKey.privateExponent.toString()},
        SetOptions(merge: true));

    var cert = {
      "IssuedBy": "",
      "ReceivedBy": "Alice",
      "message": "",
      "PublicKey": alicePubKey.publicExponent.toString(),
    };

    db
        .collection("Users")
        .doc("Alice")
        .collection("Certificates")
        .doc()
        .set(cert, SetOptions(merge: true));
  }

  void signing() {
    // make a string: "${new participant} belongs to ${lesson}"
    String plainText = "This is a test msg";

    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var adminPubKey = res.publicKey as RSAPublicKey;
    var adminPriKey = res.privateKey as RSAPrivateKey;

    var signed = rsaHelper.rsaSign(adminPriKey, plainText);
    print(signed);

    var cert = {
      "IssuedBy": "Admin",
      "message": plainText,
      "encryptedMsg": signed,
    };

    db
        .collection("Users")
        .doc("Alice")
        .collection("Certificates")
        .doc()
        .set(cert, SetOptions(merge: true));

    var readSigned = rsaHelper.rsaVerify(adminPubKey, plainText, signed);
    print(readSigned);
  }

  void updateCertBase() {}
}
