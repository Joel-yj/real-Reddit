import 'package:flutter/material.dart';

class CreateCertFormPage extends StatefulWidget {
  @override
  _CreateCertFormPage createState() => _CreateCertFormPage();
}

class _CreateCertFormPage extends State<CreateCertFormPage> {
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(
                labelText: "issueBy",
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "receiveBy",
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "PublicKey",
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "issueBy",
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 150,top: 40),
              child: MaterialButton(
                  child: const Text('Submit'),
                  onPressed: null),
            )
          ],
        ),
      ),
    );
  }
}
