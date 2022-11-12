import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/home_page.dart';

class CreateCertFormPage extends StatefulWidget {
  const CreateCertFormPage({super.key, required this.group});

  final String group;
  @override
  _CreateCertFormPage createState() => _CreateCertFormPage();
}

class _CreateCertFormPage extends State<CreateCertFormPage> {
  var cert = CertificateTemplate();

  @override
  Widget build(BuildContext context) {
    // TODO: implement Cert form builder
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Certificate of ${widget.group}'),
        ),
      ),
    );
  }
}
