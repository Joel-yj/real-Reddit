import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';

import '../objects/trustedSource.dart';

class CertCheckHelper {
  var db = FirebaseFirestore.instance;

  // returns TRUE for if all the certs are valid, else FALSE
  // 1) get trusted source pub key
  // 2) dumb out all cert of users in certificate, manage with data struct
  // 3) go thru certs in a chain to check validity
  Future<bool> checking(String oldUser, String newUser) async {
    //TODO: remove after testing
    // String oldUser = "chow"; // TODO:user is chow joins test-class1
    // String newUser = "jason";
    List<CertificateTemplate> listOfCert = [];

    print("$oldUser checking $newUser");

    // Look in trust store find "Root"
    // generate TrustedSource("Root", Root Public Key)
    var sourceDB = db
        .collection("Users/$oldUser/TrustedSource")
        .doc("Root")
        .get()
        .then((DocumentSnapshot doc) {
      print("trusted source ${doc.exists}");
      final data = doc.data() as Map<String, dynamic>;
      // print(data["Modulus"] as String);

      var builtSource = TrustedSource.fromJson(data);
      // print(builtSource.id);  // DEBUGGING
      // print(builtSource.key!.modulus);

      //  retrive Root public key
      // RSAPublicKey rebuildKey = RSAPublicKey(
      //     BigInt.parse(data["Modulus"] as String),
      //     BigInt.parse(data["PublicKey"] as String));

      // var builtSource = TrustedSource(
      //   id: data["id"],
      //   key: rebuildKey,
      // );
      // print(builtSource.id);

      return builtSource;
    });
    // var source = TrustedSource(id: "testRoot", key: await trustKey); // TODO:BUG
    var source = await sourceDB;

    //------ create Data Structures of all certs
    // certs of current user
    var allCert =
        db.collection("Users/$newUser/Certificates").get().then((res) {
      List<CertificateTemplate> list = [];
      var certificate = CertificateTemplate();
      for (var certJson in res.docs) {
        // print(certJson.id);
        var cert = certificate.fromJson(certJson.data());
        list.add(cert);
      }
      return list;
    });

    listOfCert = await allCert;
    var issuerKey = source.key;
    // print("length of cert in newUser ${listOfCert.length}");
    // print("issuer key: ${issuerKey!.modulus}");

    Map<String?, int> hashMap = {
      for (var cert in listOfCert) cert.issueBy: listOfCert.indexOf(cert)
    };

    print(hashMap);
    //----------------- End of Section
    // print(source.id);

    if (!hashMap.containsKey("Root")) {
      print("the certs in new guy dont have a cert signed by trustedSource");
      return false;
    }

    var currentCert = listOfCert[hashMap[source.id as String] as int];
    // print(currentCert);
    // print("start of chain: ${currentCert.issueBy}");
    do {
      var validity = currentCert.verifyCert2(issuerKey!);
      print("cert is valid: $validity");
      if (!validity) return false;

      if (currentCert.receiveBy == newUser) break;
      issuerKey = currentCert.subPubKey;
      currentCert = listOfCert[hashMap[currentCert.receiveBy] as int];
    } while (true);

    return true;
  }
}
