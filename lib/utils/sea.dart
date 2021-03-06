import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

// ignore: implementation_imports
import 'package:pointycastle/src/platform_check/platform_check.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:aes_crypt/aes_crypt.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart'
    hide RSAPrivateKey, RSAPublicKey;
import 'package:encrypt/encrypt.dart' hide SecureRandom;
import "package:pointycastle/export.dart" hide Signer, RSASigner;
import 'package:path/path.dart' as path;
import 'package:asn1lib/asn1lib.dart';
import 'package:crypto/crypto.dart';
import 'package:archive/archive_io.dart';

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

  static String encrypt(String data, Pair key) {
    final publicKey = parseRSAPublicKeyPEM(key.pub);

    final encrypter = Encrypter(RSA(publicKey: publicKey));
    return encrypter.encrypt(data).base64;
  }

  static String encryptForAddress(String data, String pub) {
    final publicKey = parseRSAPublicKeyPEM(pub);

    final encrypter = Encrypter(RSA(publicKey: publicKey));
    return encrypter.encrypt(data).base64;
  }

  static String decrypt(String data, Pair key) {
    final privKey = parseRSAPrivateKeyPEM(key.priv);

    final decrypter = Encrypter(RSA(privateKey: privKey));
    return decrypter.decrypt(Encrypted.fromBase64(data));
  }

  static String sign(String data, Pair key) {
    final privKey = parseRSAPrivateKeyPEM(key.priv);
    final signer = Signer(RSASigner(RSASignDigest.SHA256, privateKey: privKey));

    return signer.sign(data).base64;
  }

  static bool verify(Pair key, String data, String expected) {
    final publicKey = parseRSAPublicKeyPEM(key.pub);
    final signer =
        Signer(RSASigner(RSASignDigest.SHA256, publicKey: publicKey));

    return signer.verify64(data, expected);
  }

  static bool verifyViaAddress(String pub, String data, String expected) {
    final publicKey = parseRSAPublicKeyPEM(pub);
    final signer =
        Signer(RSASigner(RSASignDigest.SHA256, publicKey: publicKey));

    return signer.verify64(data, expected);
  }

  static String hash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  static Future<String> hashFile(String filename) async {
    return sha256
        .convert(utf8.encode(await File(filename).readAsString()))
        .toString();
  }

  static String work(String data, int length) {
    return String.fromCharCodes(
        KeyDerivator('Scrypt').process(Uint8List.fromList(data.codeUnits)));
  }

  static void encryptFile(String filename, Pair key) {
    final passKey = base64Url
        .encode(List<int>.generate(32, (i) => Random.secure().nextInt(256)));

    var crypt = AesCrypt();
    crypt.setPassword(passKey);
    crypt.setOverwriteMode(AesCryptOwMode.on);
    try {
      File sign = File('sign.txt');
      sign.writeAsString(encrypt(passKey, key));
      final String encrypted = crypt.encryptFileSync(filename);
      var encoder = ZipFileEncoder();
      encoder.create('${path.basenameWithoutExtension(filename)}.zip');
      encoder.addFile(File(encrypted));
      encoder.addFile(sign);
      encoder.close();
    } on AesCryptException {
      throw ("Error in File Encryption!");
    }
  }

  static void decryptFile(String filename, Pair key) async {
    final bytes = File(filename).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final name = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('${path.dirname(filename)}/' + name)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      }
    }

    String sign =
        await File('${path.dirname(filename)}/sign.txt').readAsString();

    var crypt = AesCrypt();
    crypt.setPassword(decrypt(sign, key));
    crypt.setOverwriteMode(AesCryptOwMode.on);

    try {
      crypt.decryptFileSync(
          '${path.dirname(filename)}/${path.basenameWithoutExtension(filename)}.txt.aes');
    } on AesCryptException {
      throw ("Error in File Decryption!");
    }
  }
}
