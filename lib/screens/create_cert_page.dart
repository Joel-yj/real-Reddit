import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/home_page.dart';
import 'package:real_reddit/objects/certificate.dart';

class CreateCertFormPage extends StatefulWidget {
  const CreateCertFormPage({super.key, required this.group, required this.user});
  final String user;
  final String group;
  @override
  _CreateCertFormPage createState() => _CreateCertFormPage();
}

class _CreateCertFormPage extends State<CreateCertFormPage> {
  var cert = CertificateTemplate();
  late CertificateTemplate newCert;

  @override
  Widget build(BuildContext context) {
    // TODO: implement Cert form builder
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Certificate of ${widget.group}'),
        ),
        body: Container(
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 35),
                      children: [
                        TextSpan(text: "Issued By: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "${widget.group}"),
                      ]
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(fontSize: 35),
                        children: [
                          TextSpan(text: "Received By: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${widget.user}"),
                        ]
                    ),
                  ),
                ),
                // Align(
                //   child: ListTile(
                //     title: Text("Public Key : "),
                //     trailing: ElevatedButton.icon(onPressed: cert.request(), icon: Icon(Icons.generating_tokens), label: Text("Generate")),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
