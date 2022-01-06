import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

// ignore: implementation_imports
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'
    hide RSAPrivateKey, RSAPublicKey;
import 'package:encrypt/encrypt.dart' hide SecureRandom;
import 'package:asn1lib/asn1lib.dart';
import "package:pointycastle/export.dart";
import 'package:crypto/crypto.dart';

import 'pair.dart';

class SEA {
  static Pair pair() {
    final _secureRandom = SecureRandom('Fortuna')
      ..seed(
          KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
    final _keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
          _secureRandom));

    final _pair = _keyGen.generateKeyPair();
    final _publicKey = _pair.publicKey as RSAPublicKey;
    final _privateKey = _pair.privateKey as RSAPrivateKey;

    var algorithmSeq = ASN1Sequence();
    var algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList(
        [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
    var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
    algorithmSeq.add(algorithmAsn1Obj);
    algorithmSeq.add(paramsAsn1Obj);

    var pub = ASN1Sequence();
    pub.add(ASN1Integer(_publicKey.modulus!));
    pub.add(ASN1Integer(_publicKey.exponent!));
    var publicKeySeqBitString =
        ASN1BitString(Uint8List.fromList(pub.encodedBytes));
    var topLevelSeqA = ASN1Sequence();
    topLevelSeqA.add(algorithmSeq);
    topLevelSeqA.add(publicKeySeqBitString);
    var pubStr =
        """-----BEGIN PUBLIC KEY-----\r\n${base64.encode(topLevelSeqA.encodedBytes)}\r\n-----END PUBLIC KEY-----""";

    var priv = ASN1Sequence();
    var version = ASN1Integer(BigInt.from(0));
    var modulus = ASN1Integer(_privateKey.n!);
    var publicExponent = ASN1Integer(BigInt.parse('65537'));
    var privateExponent = ASN1Integer(_privateKey.privateExponent!);
    var p = ASN1Integer(_privateKey.p!);
    var q = ASN1Integer(_privateKey.q!);
    var dP = _privateKey.privateExponent! % (_privateKey.p! - BigInt.from(1));
    var exp1 = ASN1Integer(dP);
    var dQ = _privateKey.privateExponent! % (_privateKey.q! - BigInt.from(1));
    var exp2 = ASN1Integer(dQ);
    var iQ = _privateKey.q!.modInverse(_privateKey.p!);
    var co = ASN1Integer(iQ);
    priv.add(version);
    priv.add(modulus);
    priv.add(publicExponent);
    priv.add(privateExponent);
    priv.add(p);
    priv.add(q);
    priv.add(exp1);
    priv.add(exp2);
    priv.add(co);
    var publicKeySeqOctetString =
        ASN1OctetString(Uint8List.fromList(priv.encodedBytes));

    var topLevelSeqB = ASN1Sequence();
    topLevelSeqB.add(version);
    topLevelSeqB.add(algorithmSeq);
    topLevelSeqB.add(publicKeySeqOctetString);

    var privStr =
        """-----BEGIN PRIVATE KEY-----\r\n${base64.encode(topLevelSeqB.encodedBytes)}\r\n-----END PRIVATE KEY-----""";
    return Pair(pubStr, privStr);
  }

  static String encrypt(String data, Pair pair) {
    var cipher = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(pair.pub as RSAPublicKey));
    var cipherText = cipher.process(Uint8List.fromList(data.codeUnits));

    return String.fromCharCodes(cipherText);
  }

  static String decrypt(String data, Pair pair) {
    final publicKey = parseRSAPublicKeyPEM(pair.pub);
    final privKey = parseRSAPrivateKeyPEM(pair.priv);

    final decrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privKey));
    return decrypter.decrypt(Encrypted.fromBase64(data));
  }

  static String sign(String data, Pair pair) {
    final sha256Sign = hash(data);
    final rsa256Sign = encrypt(sha256Sign, pair);

    return data + rsa256Sign;
  }

  static bool verify(String data, Pair pair) {
    final sha256Sign = hash(data);
    final rsa256Sign = decrypt(data, pair);

    return sha256Sign == rsa256Sign;
  }

  static String hash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  static String work(String data, int length) {
    var rand = Random();
    return List.generate(length, (index) => data[rand.nextInt(data.length)])
        .join();
  }

  static void encryptFile(String path, Pair key) {
    throw ("Not yet made");
  }

  static void decryptFile(String path, Pair key) {
    throw ("Not yet made");
  }
}
