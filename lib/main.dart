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
            FloatingActionButton(onPressed: () {
              // check issued by
            }),
          ],
        ),
      ),
      // home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
