import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/group_view_page.dart';
import 'package:real_reddit/screens/home_page.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CertViewPage extends StatefulWidget {
  const CertViewPage(
      {super.key,
      required this.group,
      required this.user,
      required this.res,
      required this.valid});
  final String user;
  final String group;
  final AsymmetricKeyPair res;
  final bool valid;
  @override
  _CertViewPage createState() => _CertViewPage();
}

class _CertViewPage extends State<CertViewPage> {
  var rsaHelper = RsaKeyHelper();
  CertificateTemplate cert = CertificateTemplate();
  var db = FirebaseFirestore.instance;
  late String message = "${widget.user} belongs to ${widget.group}";
  bool genEncryptedMsg = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement Cert form builder
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Certificate Viewer'),
        ),
      ),
    );
  }
}
