import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/home_page.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class CreateCertFormPage extends StatefulWidget {
  const CreateCertFormPage(
      {super.key, required this.group, required this.user});
  final String user;
  final String group;
  @override
  _CreateCertFormPage createState() => _CreateCertFormPage();
}

class _CreateCertFormPage extends State<CreateCertFormPage> {
  var cert = CertificateTemplate();
  var rsaHelper = RsaKeyHelper();
  final String message = "This is a test message";
  var db = FirebaseFirestore.instance;
  late CertificateTemplate newCert;
  bool showkey = false;

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
                      "Generate Key: ",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: request,
                      child: Text(
                        "Generate",
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.center,
                  child: RichText(
                    text: TextSpan(style: TextStyle(fontSize: 35), children: [
                      TextSpan(
                          text: "Message: ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: "${widget.user} belongs to ${widget.group}"),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // helper function to generate private public key of user
  void request() {
    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    var subPriKey = res.privateKey as RSAPrivateKey;

    // update firebase for User's private key
    db.collection("Users").doc(widget.user).set({
      "PrivateKey": subPriKey.privateExponent.toString(),
      "Modulus": subPriKey.modulus.toString(),
      "p": subPriKey.p.toString(),
      "q": subPriKey.q.toString()
    }, SetOptions(merge: true));
    
    db.collection("Users/Certificates")
    
  }
  //TODO: #JOEL# sign(String lesson) - input grp name
  Future<void> sign() async {

    // get {lesson} private key and sign
    var signerPrikey = db
        .collection("Users") //lesson
        .doc("CZ4010")
        .get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      // retrive signers private key
      RSAPrivateKey rebuildKey = RSAPrivateKey(
          BigInt.parse(data["Modulus"] as String),
          BigInt.parse(data["PrivateKey"] as String),
          BigInt.parse(data["p"] as String),
          BigInt.parse(data["q"] as String));

      return rebuildKey;
    });


    // // encrypt message for verification
    // encryptedMsgBytes = rsaHelper.rsaSign(await signerPrikey, message!);
    // print("in function: $encryptedMsgBytes");
  }
}
