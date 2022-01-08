import 'dart:convert';

import 'pair.dart';
import 'sea.dart';

class Identity {
  String alias;
  Pair pair;

  Identity(this.alias, this.pair);

  static Identity fromPair(String alias, Pair pair) {
    return Identity(alias, pair);
  }

  static Identity fromJson(String jsonData) {
    final data = jsonDecode(jsonData);
    return Identity(data['alias'], data['pair']);
  }

  toJson() {
    return '{"alias":$alias,"pair":{"pub":${pair.pub},"priv":${pair.priv}}}';
  }

  getID() {
    return pair.pub;
  }

  sign(String data, Pair pair) {
    return SEA.sign(data, pair);
  }
}
