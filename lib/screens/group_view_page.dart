import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class GroupViewPage extends StatefulWidget {
  @override
  _GroupViewPageState createState() => _GroupViewPageState();
}

class _GroupViewPageState extends State<GroupViewPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final titles = ["Bob", "Malicious"];

    return Scaffold(
      appBar: AppBar(
        title: Text('CZ4010'),
      ),
      body: ListView.builder(
          itemCount: titles.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(titles[index]),
                trailing: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.message),
                  label: Text('Message'),
                ),
              ),
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => CreateCertFormPage()));
            );
          }),
    );
  }
}
