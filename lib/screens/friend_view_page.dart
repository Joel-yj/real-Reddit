import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/screens/cert_view_page.dart';
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';
import 'package:real_reddit/utils/cert_check_helper.dart';
import '../objects/certificate.dart';

class FriendViewPage extends StatefulWidget {
  const FriendViewPage({
    super.key,
    required this.user,
  });
  final String user;

  @override
  _FriendViewPageState createState() => _FriendViewPageState();
}

class _FriendViewPageState extends State<FriendViewPage> {
  var rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;
  var checker = CertCheckHelper();

  @override
  Widget build(BuildContext context) {
    //TODO: search database for users
    // who have this cert and display
    final titles = ["Bob", "Malicious"];

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: ListView.builder(
          itemCount: titles.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(titles[index]),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {});
                    var valid = checker.checking(titles[index], widget.user);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CertViewPage(
                            oldUser: titles[index],
                            curUser: widget.user,
                          ),
                        ));
                  },
                  icon: Icon(Icons.message),
                  label: Text('Message'),
                ),
              ),
            );
          }),
    );
  }

  // put helper function here
}
