import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
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
  late String message = "${widget.user} belongs to ${widget.group}";
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
                      "Key: ",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        sign();
                        setState(() {
                          genEncryptedMsg = true;
                        });
                      },
                      child: Text(
                        "Generate",
                        style: TextStyle(fontSize: 30),
                      ),
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
                        style: TextStyle(fontSize: 35),),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // update firebase for User's public key
  // var certCol = db.collection("Users/Certificates");
  // certCol.where("IssueBy", isEqualTo: widget.group).get().then((value) {
  //   for (var element in value.docs) {
  //     certCol
  //         .doc(element.id)
  //         .set({"PublicKeyEx": res.publicKey.toString() as RSAPublicKey},SetOptions(merge: true));
  //   }
  // });

  //TODO: #JOEL# sign(String lesson) - input grp name
  void sign() {
    // get {lesson} private key and sign
    var signerPrikey = widget.res.privateKey as RSAPrivateKey;
    var pubKey = widget.res.publicKey as RSAPublicKey;
    // encrypt message for verification
    cert.encryptedMsgBytes = rsaHelper.rsaSign(signerPrikey, message!);

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

    print("in function: ${cert.encryptedMsgBytes}");
  }

  //decrypt message
  ///TODO: #JOEL# verifyCert(String lesson) - input grp name
  // bool verifyCert() {
  //   //get signers public key
  //   var signer = widget.group;
  //   var signerKey = widget.priKey;
  //
  //
  //
  //     RSAPublicKey pubKey =
  //     RSAPublicKey(signerKey.modulus!, BigInt.from(65537));
  //     return pubKey;
  //
  //   // get the cert contain 1) plaintext, 2) signed
  //   var validorNot = rsaHelper.rsaVerify(
  //       await signerKey, message!, encryptedMsgBytes as Uint8List);
  //   return validorNot;
  // }
}
