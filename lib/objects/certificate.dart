import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CertificateTemplate {
  String? receivedBy;
  String? issueBy;
  String? message;
  RSAPublicKey? subPubKey;
  List? encryptedMsgBytes;

  var rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;

  // Constructor
  CertificateTemplate(
      {this.receivedBy, this.issueBy, this.message, this.subPubKey});

  Map<String, dynamic> toJson() {
    return {
      "ReceivedBy": receivedBy,
      "IssueBy": issueBy,
      "PublicKeyEx": subPubKey?.publicExponent.toString(),
      "PublickeyMod": subPubKey?.modulus.toString(),
      "Message": message,
      //TODO: "EncryptedMessage" :
    };
  }

  CertificateTemplate fromJson(dynamic json) {
    RSAPublicKey rsaPublicKey = RSAPublicKey(
        BigInt.parse(json["PublickeyMod"] as String),
        BigInt.parse(json["PublicKeyEx"] as String));

    return CertificateTemplate(
      receivedBy: json["ReceiveBy"] as String,
      issueBy: json["IssueBy"] as String,
      subPubKey: rsaPublicKey,
      message: json["Message"] as String,
    );
  }

  //decrypt message
  bool verifyCert(Uint8List encryptedMsg) {
    //get signers public key

    // get the cert contain 1) plaintext, 2) signed
    // var validSig = rsaHelper.rsaVerify(adminPubKey, plainText, signed);
    return true;
  }

  void request() {
    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var subPriKey = res.privateKey as RSAPrivateKey;

    // public key into the cert template
    subPubKey = res.publicKey as RSAPublicKey;

    // put receiveby(alice) TODO: no hardcode?
    receivedBy = "Alice";

    // TODO: do ELSEWHERE update firebase for Alice private key
    db.collection("Users").doc(receivedBy).set(
        {"PrivateKey": subPriKey.privateExponent.toString()},
        SetOptions(merge: true));
  }

  //TODO: #JOEL# sign(String lesson) - input grp name
  Future<void> sign() async {
    // make a string: "${new participant} belongs to ${lesson}"
    String plainText = "This is a test msg";

    // get {lesson} private key and sign
    var signerPrikey = db
        .collection("Users") //lesson
        .doc("CZ4010")
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      RSAPrivateKey rebuildKey = RSAPrivateKey(
          BigInt.parse(data["Modulus"] as String),
          BigInt.parse(data["PrivateKey"] as String),
          BigInt.parse(data["p"] as String),
          BigInt.parse(data["q"] as String));
      return rebuildKey;
    });

    encryptedMsgBytes = rsaHelper.rsaSign(await signerPrikey, plainText);
  }

  void updateCertBase() {}
}
