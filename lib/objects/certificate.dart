import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CertificateTemplate {
  String? receiveBy;
  String? issueBy;
  String? message;
  RSAPublicKey? subPubKey;
  Uint8List? encryptedMsgBytes;

  var rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;

  // Constructor
  CertificateTemplate(
      {this.receiveBy,
      this.issueBy,
      this.message,
      this.subPubKey,
      this.encryptedMsgBytes});

  Map<String, dynamic> toJson() {
    return {
      "ReceiveBy": receiveBy,
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
      receiveBy: json["ReceiveBy"] as String,
      issueBy: json["IssueBy"] as String,
      subPubKey: rebuildKey,
      message: json["Message"] as String,
      encryptedMsgBytes: json["EncryptedMessage"],
    );
  }

  //decrypt message
  ///TODO: #JOEL# verifyCert(String lesson) - input grp name
  Future<bool> verifyCert() async {
    //get signers public key
    var signer = "CZ4010";
    var signerKey =
        db.collection("Users").doc(signer).get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      // retrive signers private key
      RSAPrivateKey rebuildKey = RSAPrivateKey(
          BigInt.parse(data["Modulus"] as String),
          BigInt.parse(data["PrivateKey"] as String),
          BigInt.parse(data["p"] as String),
          BigInt.parse(data["q"] as String));

      RSAPublicKey pubKey =
          RSAPublicKey(rebuildKey.modulus!, BigInt.from(65537));
      return pubKey;
    });

    // get the cert contain 1) plaintext, 2) signed
    var validorNot = rsaHelper.rsaVerify(
        await signerKey, message!, encryptedMsgBytes as Uint8List);
    return validorNot;
  }

  void updateCertBase() {}
}
