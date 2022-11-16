import 'dart:math';

import 'package:basic_utils/basic_utils.dart';
import 'package:real_reddit/utils/rsa_key_helper.dart';

class TestRSA {
  // ****** makeshift funct for root and admin keygen
  var rsaHelp = RsaKeyHelper();

  void testRSA() {
    var keyPair = rsaHelp.getRsaKeyPair(rsaHelp.getSecureRandom());
    var pubKey = keyPair.publicKey as RSAPublicKey;
    var priKey = keyPair.privateKey as RSAPrivateKey;

    var n = pubKey.modulus;
    var e = pubKey.publicExponent;
    var d = priKey.privateExponent;
    var p = priKey.p;
    var q = priKey.q;

    // e*d mod phi(n) = 1
    print((e! * d!) % ((p! - BigInt.parse("1")) * (q! - BigInt.parse("1"))));

    var phiN = ((p - BigInt.parse("1")) * (q - BigInt.parse("1")));

    // print("test 1: n == p*q: ${n == p * q}");

    var res2 = (e * d).gcd(phiN) == BigInt.one;
    print("(e*d)mod(phi(n)) == 1? ==> $res2");

    var res3 = e.gcd(phiN) == BigInt.one;
    print("gcd(e,phi(n) == 1? ==> $res3");

    print("random plaintext encrypt and decrypt");
    var count = 100;
    var incre = 0;
    var stringList =
        StringUtils.generateRandomStrings(count, 98, special: false);
    for (var str in stringList) {
      var strBInt = BigInt.parse(str, radix: 36);
      // print(strBInt);
      var cipher = (strBInt.modPow(e, n!));
      var plainBInt = cipher.modPow(d, n);

      var res = (strBInt == plainBInt);

      if (res) incre++;
    }

    print("$count strings: $incre are true");
  }

  BigInt euclidAlgo(BigInt m, BigInt n) {
    var r = 0;
    do {
      var r = m % n;
      m = n;
      n = r;
    } while (r != 0);
    return m;
  }
}

void main(List<String> args) {
  var test = TestRSA();
  test.testRSA();
}
