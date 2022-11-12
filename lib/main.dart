import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';
import 'screens/home_page.dart';
import 'utils/dependency_provider.dart';

import 'objects/certificate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  RsaKeyHelper rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;

  void action() {
    var secureRan = rsaHelper.getSecureRandom();
    var priKeyHex =
        (rsaHelper.getRsaKeyPair(secureRan).privateKey as RSAPrivateKey)
            .modulus
            ?.toRadixString(16);

    db
        .collection("Users")
        .doc("Alice")
        .set({"PrivateKey": priKeyHex}, SetOptions(merge: true));
    setState(() {
      key = priKeyHex as String;
    });
  }

  void csr() {
    // gernrate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var alicePubKey = res.publicKey as RSAPublicKey;
    var alicePriKey = res.privateKey as RSAPrivateKey;

    // put receiveby(alice)
    // public key into the cert template
    var aliceCert = CertificateTemplate("Alice", "", "", alicePubKey);

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
        .set(cert);
  }

  var key = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSA Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Text(key),
            FloatingActionButton(onPressed: csr),
          ],
        ),
      ),
      // home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
