import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/friend_view_page.dart';
import 'package:real_reddit/screens/home_page.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/utils/cert_check_helper.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CertViewPage extends StatefulWidget {
  const CertViewPage({
    super.key,
    required this.oldUser,
    required this.curUser,
  });
  final String oldUser;
  final String curUser;
  @override
  _CertViewPage createState() => _CertViewPage();
}

class _CertViewPage extends State<CertViewPage> {
  var rsaHelper = RsaKeyHelper();
  var db = FirebaseFirestore.instance;
  var checker = CertCheckHelper();

  @override
  Widget build(BuildContext context) {
    var valid = checker.checking(widget.oldUser, widget.curUser);
    // TODO: implement Cert form builder
    return SafeArea(
      child: FutureBuilder<bool>(
        future: valid,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            // cannot find trusted source block
            return Column(
              children: [Text("data1")],
            );
          } else if (snapshot.data == true) {
            // have matching trusted source block
            return Column(
              children: [Text('data2')],
            );
          } else {
            // false trusted source block
            return Text('Error');
          }
        },
      ),
    );
  }
}
