import 'dart:core';
import 'package:petitparser/petitparser.dart';

class ParseError {
  final String message;
  final Parser? parser;
  final String? parserName;

  ParseError(this.message, {this.parser, this.parserName});

  @override
  String toString() {
    return "$message ${parserName ?? ''}";
  }
}
