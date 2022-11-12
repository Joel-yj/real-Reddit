import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';

import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';
import 'screens/home_page.dart';
import 'utils/dependency_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // print("hello world");
  // RsaKeyHelper test = RsaKeyHelper();
  // print("hello world 2");
  // var secureRan = test.getSecureRandom();
  // var res = test.getRsaKeyPair(secureRan);
  // print('hella');

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RSA Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
