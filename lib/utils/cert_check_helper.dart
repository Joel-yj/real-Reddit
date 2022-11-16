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
  Future<bool> checking() async {
    String oldUser = "chow"; // TODO:user is chow joins test-class1
    String newUser = "jason";
    List<CertificateTemplate> listOfCert = [];

    // Look in trust store find "Root"
    // generate TrustedSource("Root", Root Public Key)
    var trustKey = db
        .collection("Users/$oldUser/TrustedSource")
        .doc("Root")
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      var test = TrustedSource.fromJson(data);
      print(test.key!.publicExponent);
      //  retrive Root public key
      RSAPublicKey rebuildKey = RSAPublicKey(
          BigInt.parse(data["Modulus"] as String),
          BigInt.parse(data["PublicKey"] as String));

      return rebuildKey;
    });
    var source = TrustedSource(id: "Root", key: await trustKey);

    //------ create Data Structures of all certs
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

    Map<String?, int> hashMap = {
      for (var cert in listOfCert) cert.issueBy: listOfCert.indexOf(cert)
    };
    //----------------- End of Section

    var currentCert = listOfCert[hashMap[source.id] as int];
    do {
      var validity = currentCert.verifyCert2(issuerKey!);
      if (!validity) {
        return false;
      }

      if (currentCert.receiveBy == newUser) break;
      issuerKey = currentCert.subPubKey;
      currentCert = listOfCert[hashMap[currentCert.receiveBy] as int];
    } while (true);

    return true;
  }
}
