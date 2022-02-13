import "./lexer.dart";

enum TokenType {
  sectionHead,
  metadataEntry,
  listItem,
  listItemType,
  listItemLabel,
  listItemPropLine,
  listItemPropInline
}

class Token<T> {
  TokenType type;
  String raw;
  T value;

  Token(this.type, this.raw, this.value);
}

class Rules {
  static final Map<TokenType, RegExp> map = {
    TokenType.sectionHead: RegExp(r"^\s*===\s*[a-zA-Z0-9]+\s*==="),
    TokenType.metadataEntry: RegExp(r"^\s*[a-zA-Z0-9]+\s*=\s*[^\s]+"),
    TokenType.listItem: RegExp(
        r"^\s*[-*.]\s*[^\n\|]+(\s*\|(\s*[a-zA-Z0-9]*\s*=\s*((\{[^\}]*})|([a-zA-Z0-9]*))\s*,?)+\n*)*"),
    TokenType.listItemType: RegExp(r"^\s*[-*.]\s*"),
    TokenType.listItemLabel: RegExp(r"^[^\n\|]+"),
    TokenType.listItemPropLine: RegExp(
        r"(\s*\|(\s*[a-zA-Z0-9]*\s*=\s*((\{[^\}]*})|([a-zA-Z0-9]*))\s*,?)+\n*)*"),
    TokenType.listItemPropInline: RegExp(
        r"(\s*[a-zA-Z0-9\-]*\s*=\s*((\{[^\}]*})|([a-zA-Z0-9\-\_]*)),?)+"),
  };
}

class Tokenizer {
  static Token? sectionStart(String stream, State state) {
    final rule = Rules.map[TokenType.sectionHead];
    if (rule == null) return null;
    final match = rule.matchAsPrefix(stream);
    if (match == null) return null;
    final raw = match[0];
    if (raw == null) return null;

    final rawTrimmed = raw.trim();
    final label =
        rawTrimmed.substring(3, rawTrimmed.length - 3).trim().toLowerCase();

    if (label != "metadata" && label != "content" && label != "progress") {
      throw Exception("Unrecognized section named $label");
    }

    state.section = label;

    return Token(TokenType.sectionHead, raw, label);
  }

  static Token<Map<String, String>>? metadataEntry(String stream, State state) {
    if (state.section != "metadata") return null;
    final rule = Rules.map[TokenType.metadataEntry];
    if (rule == null) return null;
    final match = rule.matchAsPrefix(stream);
    if (match == null) return null;
    final raw = match[0];
    if (raw == null) return null;

    final _arr = raw.split(".");
    final key = _arr[0].trim();
    final value = _arr[1].trim();

    return Token(TokenType.metadataEntry, raw, {"key": key, "value": value});
  }
}
