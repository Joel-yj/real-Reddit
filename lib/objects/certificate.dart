import 'dart:convert';
import 'dart:html';

import 'package:basic_utils/basic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
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
  var storage = LocalStorage("UsersKey");

  late RSAPrivateKey subPriKey;

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

    List<int> toList = (List.from(json["EncryptedMessage"]));
    return CertificateTemplate(
      receiveBy: json["ReceiveBy"] as String,
      issueBy: json["IssueBy"] as String,
      subPubKey: rebuildKey,
      message: json["Message"] as String,
      encryptedMsgBytes: Uint8List.fromList(toList),
    );
  }

  void step1() {
    receiveBy = "gogo";
    issueBy = "more-test";

    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    subPriKey = res.privateKey as RSAPrivateKey;

    // public key into the cert template
    subPubKey = res.publicKey as RSAPublicKey;
  }

  Future<void> step2() async {
    // sign; gernerate encrypted msg

    // make a string: "${new participant} belongs to ${lesson}"
    message = "$issueBy signs for $receiveBy";

    // get {lesson} private key and sign
    var signerPrikey = db
        .collection("Users") //lesson
        .doc(issueBy)
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

    // Getting Private Key from Local Storage http://localhost:8000/#/
    // await storage.ready;
    // var out = await storage.getItem("$receiveBy-$issueBy");
    // RSAPrivateKey shouldbe = CryptoUtils.rsaPrivateKeyFromPem(out);

    // encrypt message for verification
    encryptedMsgBytes = rsaHelper.rsaSign(await signerPrikey, message!);
    print("in function: $encryptedMsgBytes");
  }

  void step3push() {
    // -------push to store private key
    var subPriJson = {
      "PrivateKey": subPriKey.privateExponent.toString(),
      "Modulus": subPriKey.modulus.toString(),
      "p": subPriKey.p.toString(),
      "q": subPriKey.q.toString(),
    };

    db
        .collection("Users/$receiveBy/PrivateKeyCollection")
        .doc(issueBy)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        // put into db if dont have key yet
        db
            .collection("Users/$receiveBy/PrivateKeyCollection")
            .doc(issueBy)
            .set(subPriJson, SetOptions(merge: true));

        // store to Local Storage of http://localhost:8000/#/
        var priKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(subPriKey);
        await storage.ready;
        storage.setItem("$receiveBy-$issueBy", priKeyPEM); // store as PEM
        // print(await storage.getItem("$receiveBy-$issueBy"));
      } else {
        // got key for tat class
        // TODO: refresh only if invalid
        print("already exist");
      }
    });
    // -----------end of storing private Key
    print(receiveBy);
    print(issueBy);
    //TODO: only store cert if uniqued
    db
        .collection("Users/$receiveBy/Certificates")
        .where("IssueBy", isEqualTo: issueBy)
        .where("ReceiveBy", isEqualTo: receiveBy)
        .get()
        .then((res) {
      if (res.docs.isEmpty) {
        print("in storing");
        // Store certificate
        var certJson = toJson();
        db
            .collection("Users/$receiveBy/Certificates")
            .doc()
            .set(certJson, SetOptions(merge: true));
      } else {
        // TODO: refresh cert?? only if invalid
        print("HAVE: $issueBy give to $receiveBy");
      }
    });
  }

//---------------processes-----------
  Future<void> request() async {
    // *NEW* get both issue and receive by HERE
    receiveBy = "gogo";
    issueBy = "CE33";

    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var subPriKey = res.privateKey as RSAPrivateKey;

    //  update local storage & firebase for Alice private key
    //
    //  local storage stores in key-value pairKey
    //  Key = "$receiveBy-$lesson"
    //  value = Private Key in PEM format

    var subPriJson = {
      "PrivateKey": subPriKey.privateExponent.toString(),
      "Modulus": subPriKey.modulus.toString(),
      "p": subPriKey.p.toString(),
      "q": subPriKey.q.toString(),
    };

    db
        .collection("Users/$receiveBy/PrivateKeyCollection")
        .doc(issueBy)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        // put into db if dont have key yet
        db
            .collection("Users/$receiveBy/PrivateKeyCollection")
            .doc(issueBy)
            .set(subPriJson, SetOptions(merge: true));

        // store to Local Storage of http://localhost:8000/#/
        var priKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(subPriKey);
        await storage.ready;
        storage.setItem("$receiveBy-$issueBy", priKeyPEM); // store as PEM
        // print(await storage.getItem("$receiveBy-$issueBy"));
      } else {
        // got key for tat class
        // TODO: refresh only if invalid
        print("already exist");
      }
    });

    // public key into the cert template
    subPubKey = res.publicKey as RSAPublicKey;
  }

  Future<void> passOnCert() async {
    // pass on cert from admin to user
    // OR pass on cert from new to old user (maybe not)

    var fromOne = "class";
    var toAnother = "zebra";

    var fromRef = db.collection("Users/$fromOne/Certificates");
    var toRef = db.collection("Users/$toAnother/Certificates");

    var copyCerts = await fromRef.where("ReceiveBy", isEqualTo: fromOne).get();
    var writeBatch = db.batch();
    for (var doc in copyCerts.docs) {
      writeBatch.set(toRef.doc(doc.id), doc.data());
      await writeBatch.commit();
    }
  }

  //TODO: #JOEL# sign(String lesson) - input grp name
  Future<void> sign() async {
    // make a string: "${new participant} belongs to ${lesson}"
    message = "$issueBy signs for $receiveBy";

    // get {lesson} private key and sign
    var signerPrikey = db
        .collection("Users") //lesson
        .doc(issueBy)
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

    // Getting Private Key from Local Storage http://localhost:8000/#/
    await storage.ready;
    var out = await storage.getItem("$receiveBy-$issueBy");
    RSAPrivateKey shouldbe = CryptoUtils.rsaPrivateKeyFromPem(out);

    // encrypt message for verification
    encryptedMsgBytes = rsaHelper.rsaSign(await signerPrikey, message!);
    print("in function: $encryptedMsgBytes");
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

  bool verifyCert2(RSAPublicKey signerKey) {
    // get the cert contain 1) plaintext, 2) signed
    // print(message);
    // print(encryptedMsgBytes);

    var validorNot = rsaHelper.rsaVerify(
        signerKey, message!, encryptedMsgBytes as Uint8List);
    return validorNot;
  }
}
