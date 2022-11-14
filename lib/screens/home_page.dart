import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

import 'create_cert_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: might need to turn listview cards into children

    final group = ["CZ4010", "CZ4020"];
    const user = "Alice";

    return Scaffold(
      appBar: AppBar(
        title: Text('RSA Certificate App'),
      ),
      body: ListView.builder(
          itemCount: group.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(group[index]),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateCertFormPage(group: group[index], user: user),
                      ),
                    );
                  },
                  icon: Icon(Icons.group_add_sharp),
                  label: Text('Join'),
                ),
              ),
            );
          }),
    );
  }
}
