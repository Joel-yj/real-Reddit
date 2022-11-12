import 'package:flutter/material.dart';
import 'cert_view.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:real_reddit/utils/dependency_provider.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

// TextStyle get whiteTextStyle => TextStyle(color: Colors.white);

class MyHomePage extends StatefulWidget {
  MyHomePage({key, required this.title}) : super(key: key);
  final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

class _MyHomePageState extends State<MyHomePage> {
  // /// The Future that will show the Pem String
  // late Future<String> futureText;
  //
  // /// Future to hold the reference to the KeyPair generated with PointyCastle
  // /// in order to extract the [crypto.PrivateKey] and [crypto.PublicKey]
  // late crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>
  //     futureKeyPair;
  //
  // /// The current [crypto.AsymmetricKeyPair]
  // //crypto.AsymmetricKeyPair keyPair = getKeyPair();
  //
  // /// With the helper [RsaKeyHelper] this method generates a
  // /// new [crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>
  // Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
  //     getKeyPair() {
  //   var keyHelper = DependencyProvider.of(context).getRsaKeyHelper();
  //   return keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom());
  // }
  //
  // /// GlobalKey to be used when showing the [Snackbar] for the successful
  // /// copy of the Key
  // final key = GlobalKey<ScaffoldState>();
  //
  // /// Text Editing Controller to retrieve the text to sign
  // final TextEditingController _controller = TextEditingController();

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

      // body: Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.stretch,
      //       children: <Widget>[
      //         MaterialButton(
      //           color: Theme.of(context).colorScheme.secondary,
      //           child: Text(
      //             "Generate new Key Pair",
      //             style: whiteTextStyle,
      //           ),
      //           onPressed: () {
      //             setState(() {
      //               // If there are any pemString being shown, then show an empty message
      //               futureText = Future.value("");
      //               // Generate a new keypair
      //               // TODO : generate keypair here
      //             });
      //           },
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
