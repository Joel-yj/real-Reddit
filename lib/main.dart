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

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  void action() {
    print("hello world");
    RsaKeyHelper test = RsaKeyHelper();
    print("hello world 2");
    var secureRan = test.getSecureRandom();
    var res = (test.getRsaKeyPair(secureRan).privateKey as RSAPrivateKey)
        .modulus
        ?.toRadixString(16);
    setState(() {
      key = res as String;
    });
    print('hella');
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
            FloatingActionButton(onPressed: action),
          ],
        ),
      ),
      // home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}
