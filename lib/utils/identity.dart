import 'pair.dart';
import 'sea.dart';

class Identity {
  String alias;
  Pair pair;

  Identity(this.alias, this.pair);

  static Identity fromPair(String alias, Pair pair) {
    return Identity(alias, pair);
  }

  static Identity fromJson(String alias, Pair pair) {
    throw ("Not yet made");
  }

  toJson() {
    throw ("Not yet made");
  }

  getID() {
    return pair.pub;
  }

  sign(String data, Pair pair) {
    return SEA.sign(data, pair);
  }
}
