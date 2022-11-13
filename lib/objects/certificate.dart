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
  Uint8List? encryptedMsgBytes;

  var rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;

  // Constructor
  CertificateTemplate(
      {this.receivedBy,
      this.issueBy,
      this.message,
      this.subPubKey,
      this.encryptedMsgBytes});

  Map<String, dynamic> toJson() {
    print(encryptedMsgBytes);
    var test = jsonEncode(encryptedMsgBytes);
    print(test);
    return {
      "ReceivedBy": receivedBy,
      "IssueBy": issueBy,
      "PublicKeyEx": subPubKey?.publicExponent.toString(),
      "PublickeyMod": subPubKey?.modulus.toString(),
      "Message": message,
      "EncryptedMessage": encryptedMsgBytes,
    };
  }

  CertificateTemplate fromJson(dynamic json) {
    RSAPublicKey rebuildKey = RSAPublicKey(
        BigInt.parse(json["PublickeyMod"] as String),
        BigInt.parse(json["PublicKeyEx"] as String));

    return CertificateTemplate(
      receivedBy: json["ReceiveBy"] as String,
      issueBy: json["IssueBy"] as String,
      subPubKey: rebuildKey,
      message: json["Message"] as String,
      encryptedMsgBytes: json["EncryptedMessage"],
    );
  }

  //decrypt message
  ///TODO: #JOEL# verifyCert(String lesson) - input grp name
  bool verifyCert() {
    //get signers public key
    var signer = "CZ4010";
    var signerKey = RSAPublicKey(
        BigInt.parse(
            "7501247414949680357271830569015946137768662669558036024010149845928554960295592509389092769892444240588123263867599066019833146675988887468577890112722923"),
        BigInt.parse("65537"));

    print(message);
    // get the cert contain 1) plaintext, 2) signed
    var validorNot = rsaHelper.rsaVerify(
        signerKey, message!, encryptedMsgBytes as Uint8List);
    return validorNot;
  }

  void request() {
    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var subPriKey = res.privateKey as RSAPrivateKey;

    // put receiveby(alice) TODO: no hardcode?
    receivedBy = "dad";

    // TODO: do ELSEWHERE
    // update firebase for Alice private key
    db.collection("Users").doc(receivedBy).set({
      "PrivateKey": subPriKey.privateExponent.toString(),
      "Modulus": subPriKey.modulus.toString(),
      "p": subPriKey.p.toString(),
      "q": subPriKey.q.toString()
    }, SetOptions(merge: true));

    // public key into the cert template
    subPubKey = res.publicKey as RSAPublicKey;
  }

  //TODO: #JOEL# sign(String lesson) - input grp name
  Future<void> sign() async {
    // make a string: "${new participant} belongs to ${lesson}"
    message = "This is a test msg";

    // get {lesson} private key and sign
    var signerPrikey = db
        .collection("Users") //lesson
        .doc("CZ4010")
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      // retrive signers private key
      RSAPrivateKey rebuildKey = RSAPrivateKey(
          BigInt.parse(data["Modulus"] as String),
          BigInt.parse(data["PrivateKey"] as String),
          BigInt.parse(data["p"] as String),
          BigInt.parse(data["q"] as String));
      return rebuildKey;
    });

    // encrypt message for verification
    encryptedMsgBytes = rsaHelper.rsaSign(await signerPrikey, message!);
  }

  void updateCertBase() {}
}
