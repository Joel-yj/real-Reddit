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
      "PublicKeyMod": subPubKey?.modulus.toString(),
      "Message": message,
      "EncryptedMessage": encryptedMsgBytes,
    };
  }

  CertificateTemplate fromJson(dynamic json) {
    RSAPublicKey rebuildKey = RSAPublicKey(
        BigInt.parse(json["PublicKeyMod"] as String),
        BigInt.parse(json["PublicKeyEx"] as String));

    return CertificateTemplate(
      receiveBy: json["ReceiveBy"] as String,
      issueBy: json["IssueBy"] as String,
      subPubKey: rebuildKey,
      message: json["Message"] as String,
      encryptedMsgBytes: json["EncryptedMessage"],
    );
  }

  void updateCertBase() {}
}
