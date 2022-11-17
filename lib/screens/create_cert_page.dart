import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/friend_view_page.dart';
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
  late String msg;

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
                          step2();
                          msg = getEncryptedMsg();
                          setState(() => genEncryptedMsg = true);
                        },
                        child: Text(
                          "Request",
                          style: TextStyle(fontSize: 30),
                        ),
                      ),
                    if (genEncryptedMsg == true)
                      Text(
                        "Certificate Generated",
                        style: TextStyle(fontSize: 35),
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
                        child: Text(cert.encryptedMsgBytes.toString(),
                        style: TextStyle(fontSize: 35),),
                      ),
                    ],
                  ),
                if (genEncryptedMsg == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: Size(165, 50),
                        ),
                        onPressed: () {
                          //TODO Put the db writing function here
                          step3push();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendViewPage(
                                user: widget.user,
                              ),
                            ),
                          );
                        },
                        child: Text("Submit"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(165, 50),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> step2() async {
    // sign; gernerate encrypted msg
    // var signerPrikey = widget.res.privateKey as RSAPrivateKey;
    print("in step 2");
    var issuer = widget.group;
    var pubKey = widget.res.publicKey as RSAPublicKey;

    print(issuer);
    // get {lesson} private key and sign
    var signerPrikey = db
        .collection("Users/$issuer/PrivateKeyCollection")
        .doc("Root") // TODO: find prikey issued by Root
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

    print((await signerPrikey).privateExponent);

    // Getting Private Key from Local Storage http://localhost:8000/#/
    // await storage.ready;
    // var out = await storage.getItem("$receiveBy-$issuer");
    // RSAPrivateKey shouldbe = CryptoUtils.rsaPrivateKeyFromPem(out);

    // encrypt message for verification
    cert.encryptedMsgBytes = rsaHelper.rsaSign(await signerPrikey, message);
    // print("in function: $encryptedMsgBytes");

    // TODO: store fields into cert
    cert.issueBy = issuer;
    cert.message = message;
    cert.receiveBy = widget.user;
    cert.subPubKey = pubKey;

    print(cert.receiveBy);
    print(cert.issueBy);
    print(cert.message);
    print(cert.encryptedMsgBytes);
  }

//   CertificateTemplate sign() {
//     // get {lesson} private key and sign
//     var signerPrikey = widget.res.privateKey as RSAPrivateKey;
//     var pubKey = widget.res.publicKey as RSAPublicKey;
//     // encrypt message for verification
//     cert.encryptedMsgBytes = rsaHelper.rsaSign(signerPrikey, message);

//     db.collection("Users/${widget.user}/Certificates").doc().set(
//       {
//         "IssueBy": widget.group,
//         "Message": message,
//         "PublicKeyEx": pubKey.publicExponent.toString(),
//         "ReceiveBy": widget.user,
//         "PublicKeyMod": pubKey.modulus.toString(),
//         "EncryptedMessage": cert.encryptedMsgBytes
//       },
//     );
//     return cert;

//     //print("in function: ${cert.encryptedMsgBytes}");
//   }
  String getEncryptedMsg() {
    var user = widget.user;


    print(cert.encryptedMsgBytes.toString());
    // get {lesson} private key and sign
    Future<String> test = db
        .collection("Users/$user/Certificates")
        .where('ReceiveBy', isEqualTo: user)
        .get()
        .then((value) {
      for (var element in value.docs) {
        String msg = element['EncryptedMessage'].toString();
        return msg;
      }
      return '';
    });
    test.then((value) => msg = value);
    return msg;
  }

  void step3push() {
    var subPriKey = widget.res.privateKey as RSAPrivateKey;
    var receiveBy = widget.user;
    var issueBy = widget.group;
    var storage = LocalStorage("UsersKey");

    // -------push to store private key
    var subPriJson = {
      "PrivateKey": subPriKey.privateExponent.toString(),
      "Modulus": subPriKey.modulus.toString(),
      "p": subPriKey.p.toString(),
      "q": subPriKey.q.toString(),
    };

    db
        .collection("Users/$receiveBy/PrivateKeyCollection")
        .doc(issueBy)
        .get()
        .then((doc) async {
      if (!doc.exists) {
        // put into db if dont have key yet
        db
            .collection("Users/$receiveBy/PrivateKeyCollection")
            .doc(issueBy)
            .set(subPriJson, SetOptions(merge: true));

        // store to Local Storage of http://localhost:8000/#/
        var priKeyPEM = CryptoUtils.encodeRSAPrivateKeyToPem(subPriKey);
        await storage.ready;
        storage.setItem("$receiveBy-$issueBy", priKeyPEM); // store as PEM
        // print(await storage.getItem("$receiveBy-$issueBy"));
      } else {
        // got key for tat class
        // TODO: refresh only if invalid
        print("already have private key exist");
      }
    });
    // -----------end of storing private Key
    print(receiveBy);
    print(issueBy);
    // -------Store cert if uniqued
    db
        .collection("Users/$receiveBy/Certificates")
        .where("IssueBy", isEqualTo: issueBy)
        .where("ReceiveBy", isEqualTo: receiveBy)
        .get()
        .then((res) {
      if (res.docs.isEmpty) {
        print("in storing");
        // Store certificate
        var certJson = cert.toJson();
        db
            .collection("Users/$receiveBy/Certificates")
            .doc()
            .set(certJson, SetOptions(merge: true));

        // pass the parent cert
        passOnCert(issueBy, receiveBy);
      } else {
        // TODO: refresh cert?? only if invalid
        print("HAVE: $issueBy give to $receiveBy");
      }
    });

    // -------End of store cert
  }

  void passOnCert(String fromOne, String toAnother) async {
    var fromRef = db.collection("Users/$fromOne/Certificates");
    var toRef = db.collection("Users/$toAnother/Certificates");

    var copyCerts = await fromRef.where("ReceiveBy", isEqualTo: fromOne).get();
    var writeBatch = db.batch();
    for (var doc in copyCerts.docs) {
      writeBatch.set(toRef.doc(doc.id), doc.data());
      await writeBatch.commit();
    }
  }
}
