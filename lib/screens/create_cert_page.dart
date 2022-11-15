import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/group_view_page.dart';
import 'package:real_reddit/screens/home_page.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CreateCertFormPage extends StatefulWidget {
  const CreateCertFormPage(
      {super.key, required this.group, required this.user, required this.res});
  final String user;
  final String group;
  final AsymmetricKeyPair res;
  @override
  _CreateCertFormPage createState() => _CreateCertFormPage();
}

class _CreateCertFormPage extends State<CreateCertFormPage> {
  var rsaHelper = RsaKeyHelper();
  CertificateTemplate cert = CertificateTemplate();
  var db = FirebaseFirestore.instance;
  late String message = "${widget.group} signs for ${widget.user}";
  bool genEncryptedMsg = false;

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
                    text: TextSpan(style: TextStyle(fontSize: 35), children: [
                      TextSpan(
                          text: "Issued By: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "${widget.group}"),
                    ]),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(style: TextStyle(fontSize: 35), children: [
                      TextSpan(
                          text: "Received By: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "${widget.user}"),
                    ]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Certificate: ",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    if (genEncryptedMsg == false)
                      ElevatedButton(
                        onPressed: () {
                          sign();
                          setState(() {
                            genEncryptedMsg = true;
                          });
                        },
                        child: Text(
                          "Request",
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    if (genEncryptedMsg == true)
                      Text(
                        "Certificate Generated",
                        style:
                        TextStyle(fontSize: 35),
                      ),
                  ],
                ),
                if (genEncryptedMsg == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text:
                            TextSpan(style: TextStyle(fontSize: 35), children: [
                          TextSpan(
                              text: "Message: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: message),
                        ]),
                      ),
                    ],
                  ),
                if (genEncryptedMsg == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text:
                            TextSpan(style: TextStyle(fontSize: 35), children: [
                          TextSpan(
                              text: "Encrypted Message: ",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      Flexible(
                        child: Text(
                          cert.encryptedMsgBytes.toString(),
                          style: TextStyle(fontSize: 35),
                        ),
                      ),
                    ],
                  ),
                if (genEncryptedMsg == true)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupViewPage(
                            group: widget.group,
                            user: widget.user,
                            res: widget.res,
                          ),
                        ),
                      );
                    },
                    child: Text("Submit"),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  CertificateTemplate sign() {
    // get {lesson} private key and sign
    var signerPrikey = widget.res.privateKey as RSAPrivateKey;
    var pubKey = widget.res.publicKey as RSAPublicKey;
    // encrypt message for verification
    cert.encryptedMsgBytes = rsaHelper.rsaSign(signerPrikey, message);

    db.collection("Users/${widget.user}/Certificates").doc().set(
      {
        "IssueBy": widget.group,
        "Message": message,
        "PublicKeyEx": pubKey.publicExponent.toString(),
        "ReceiveBy": widget.user,
        "PublicKeyMod": pubKey.modulus.toString(),
        "EncryptedMessage": cert.encryptedMsgBytes
      },
    );
    return cert;

    //print("in function: ${cert.encryptedMsgBytes}");
  }

}
