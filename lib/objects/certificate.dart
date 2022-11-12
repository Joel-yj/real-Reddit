import 'package:pointycastle/asymmetric/api.dart';

class CertificateTemplate {
  String receivedBy;
  String issueBy;
  String message;
  // String publicKey;
  RSAPublicKey test;

  CertificateTemplate(this.receivedBy, this.issueBy, this.message, this.test);
}
