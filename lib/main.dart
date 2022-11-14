import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:real_reddit/screens/create_cert_page.dart';
import 'package:real_reddit/screens/group_view_page.dart';
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

  runApp(
    MyApp(),
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
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  // var certToBe = CertificateTemplate();
  // var db = FirebaseFirestore.instance;
  // RsaKeyHelper rsahelp = RsaKeyHelper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RSA Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}
