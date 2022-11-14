import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';

import '../objects/trustedSource.dart';

class CertCheckHelper {
  var db = FirebaseFirestore.instance;

  Future<bool> checking() async {
    List<CertificateTemplate> test = [];

    // look into trust store to find
    // 1) root
    // 2) root public key
    var trustKey = db
        .collection("Users/dad/TrustedSource")
        .doc("Root")
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      //  retrive Root public key
      RSAPublicKey rebuildKey = RSAPublicKey(
          BigInt.parse(data["Modulus"] as String),
          BigInt.parse(data["PublicKey"] as String));

      return rebuildKey;
    });
    var source = TrustedSource(id: "Root", key: await trustKey);

    //create list of all certs
    var allCert = db.collection("Users/chow/Certificates").get().then((res) {
      List<CertificateTemplate> list = [];
      var certificate = CertificateTemplate();
      for (var certJson in res.docs) {
        print(certJson.id);
        var cert = certificate.fromJson(certJson.data());
        list.add(cert);
      }
      return list;
    });

    test = await allCert;
    // print(test);

    var issuerKey = source.key;

    // print(test.length);

    Map<String?, int> hashMap = {
      for (var cert in test) cert.issueBy: test.indexOf(cert)
    };

    // print(hashMap);

    var currentCert = test[hashMap["Root"] as int];

    do {
      // print(currentCert.message);
      var validity = currentCert.verifyCert2(issuerKey!);
      // print(validity);
      if (!validity) {
        return false;
      }

      if (currentCert.receiveBy == "chow") break;
      issuerKey = currentCert.subPubKey;
      // print(issuerKey!.modulus);
      currentCert = test[hashMap[currentCert.receiveBy] as int];
    } while (true);

    return true;
  }
}
