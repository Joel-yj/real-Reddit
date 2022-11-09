import 'package:flutter/material.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';
import 'screens/home_page.dart';
import 'utils/dependency_provider.dart';

void main() {
  // We need to encapsulate `MyApp` with the DependencyProvider in order
  // to be able to access the RSA KeyHelper

  print("hello world");
  RsaKeyHelper test = RsaKeyHelper();
  print("hello world 2");
  var secureRan = test.getSecureRandom();
  var res = test.getRsaKeyPair(secureRan);
  print('hella');


  // runApp(
  //     DependencyProvider(key: null,
  //     child: MyApp(),)
  // );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSA Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'RSA Key Generator'),
    );
  }
}