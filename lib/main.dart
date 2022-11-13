import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';
import 'screens/home_page.dart';

import 'objects/certificate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ****** makeshift funct for root and admin keygen
  // RsaKeyHelper kg = RsaKeyHelper();
  // var asym = kg.getRsaKeyPair(kg.getSecureRandom());
  // var pub = asym.publicKey as RSAPublicKey;
  // var pri = asym.privateKey as RSAPrivateKey;
  // print(pub.publicExponent);
  // print(pri.privateExponent);
  // print(pri.modulus);
  // print(pri.p);
  // print(pri.q);

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

  var db = FirebaseFirestore.instance;
  var certToBe = CertificateTemplate();

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
            FloatingActionButton(onPressed: () async {
              // certToBe.request();
              // await certToBe.sign(); // must put await
              // push cert to firebase
              // db
              //     .collection("Users/dad/Certificates")
              //     .doc()
              //     .set(certToBe.toJson());

              // var verified = certToBe.verifyCert();
              // print(verified);
            }),
          ],
        ),
      ),
      // home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
