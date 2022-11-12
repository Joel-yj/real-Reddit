import 'package:flutter/material.dart';
import 'cert_view.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

TextStyle get whiteTextStyle => TextStyle(color: Colors.white);

class MyHomePage extends StatefulWidget {
  MyHomePage({key, required this.title}) : super(key: key);
  final String title;

  @override
   _MyHomePageState createState() => _MyHomePageState();
 }

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: [
              Container(
                color: Colors.blue,
                margin: EdgeInsets.all(25.0),
                child: MaterialButton(
                  color: Colors.lightBlueAccent,
                  onPressed: () {
                    setState(() {
                      //TODO generate keypair here
                    });
                  },
                  child: Text(
                    "Generate new Key Pair",
                    style: whiteTextStyle,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                color: Colors.green,
                margin: EdgeInsets.all(25.0),
                child: MaterialButton(
                  color: Colors.greenAccent,
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CertViewPage(),)
                    );
                    setState(() {
                      //TODO Join group
                    });
                  },
                  child: Text(
                    "Group CZ4010",
                    style: whiteTextStyle,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
