import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:real_reddit/objects/certificate.dart';
import 'package:real_reddit/screens/friend_view_page.dart';
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';
import 'create_cert_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var rsaHelper = RsaKeyHelper();
  final user = "UserTrial";
  var db = FirebaseFirestore.instance;
  var cert = CertificateTemplate();
  late String issueBy;

  @override
  Widget build(BuildContext context) {
    // TODO: might need to turn listview cards into children

    final group = [
      "CZ4010",
      "CZ4020",
      "Root",
      "joel-test1",
      "Bob",
      "testRoot",
      "ClassTrial"
    ];
    late crypto.AsymmetricKeyPair res;

    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: ListView.builder(
          itemCount: group.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(group[index]),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      issueBy = group[index];
                    });
                    res = step1(issueBy);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateCertFormPage(
                          group: group[index],
                          user: user,
                          res: res,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.group_add_sharp),
                  label: Text('Join'),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendViewPage(
                user: user,
              ),
            ),
          );
        },
      ),
    );
  }

  // helper function to generate private public key of user
  crypto.AsymmetricKeyPair step1(String issueBy) {
    // generate key pair
    var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
    // print(issueBy);
    // print((res.publicKey as RSAPublicKey).modulus);
    return res;
  }

  // crypto.AsymmetricKeyPair request(String issueBy) {
  //   // generate key pair
  //   var res = rsaHelper.getRsaKeyPair(rsaHelper.getSecureRandom());
  //   var subPriKey = res.privateKey as RSAPrivateKey;

  //   var subPriJson = {
  //     "PrivateKey": subPriKey.privateExponent.toString(),
  //     "Modulus": subPriKey.modulus.toString(),
  //     "p": subPriKey.p.toString(),
  //     "q": subPriKey.q.toString(),
  //   };

  //   // update firebase for User's private key
  //   db
  //       .collection("Users/$user/PrivateKeyCollection")
  //       .doc(issueBy)
  //       .get()
  //       .then((doc) {
  //     if (!doc.exists) {
  //       // put into db if dont have key yet
  //       db
  //           .collection("Users/$user/PrivateKeyCollection")
  //           .doc(issueBy)
  //           .set(subPriJson, SetOptions(merge: true));
  //     } else {
  //       // got key for tat class
  //       // TODO: refresh only if invalid
  //       print("already exist");
  //     }
  //   });
  //   return res;
  // }
}
