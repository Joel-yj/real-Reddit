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
import 'package:flutterfire_ui/firestore.dart';

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
  var checker = CertCheckHelper();
  var db = FirebaseFirestore.instance;
  late String msg;

  @override
  Widget build(BuildContext context) {
    var valid = checker.checking(widget.oldUser, widget.curUser);
    var _userStream =
        db.collection("Users/${widget.curUser}/Certificates").snapshots();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Certificates'),
        ),
        body: FutureBuilder<bool>(
          future: valid,
          builder: (context, snapshot) {
            if (snapshot.data == null) {
              print(widget.oldUser);
              print(widget.curUser);
              print(snapshot.data);
              // cannot find trusted source block
              return Column(
                children: [
                  Text(
                    "${widget.oldUser} is not subset of group",
                    style: TextStyle(fontSize: 35),
                  )
                ],
              );
            } else if (snapshot.data == true) {
              // have matching trusted source block
              return StreamBuilder(
                  stream: _userStream,
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error');
                    }
                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(data['IssueBy']),
                            subtitle: Text(data['ReceiveBy']),
                          ),
                        );
                      }).toList(),
                    );
                  });
            } else {
              // false trusted source block
              return Column(
                children: [
                  Text(
                    "${widget.curUser} is not a verified User",
                    style: TextStyle(fontSize: 35),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
