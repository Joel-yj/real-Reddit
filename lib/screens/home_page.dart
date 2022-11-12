import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

import 'create_cert_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // RsaKeyHelper test = RsaKeyHelper();
    // var db = FirebaseFirestore.instance;
    // var secureRan = test.getSecureRandom();
    // var priKeyHex = (test.getRsaKeyPair(secureRan).privateKey as RSAPrivateKey)
    //     .modulus
    //     ?.toRadixString(16);

    final titles = ["CZ4010", "CZ4020"];

    return ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(titles[index]),
              trailing: Icon(Icons.add),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateCertFormPage()));
              },
            ),
          );
        });
  }
}
