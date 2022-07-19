import 'package:parser/graphql_parser/model/token.dart';

String serializeList(List<GQToken>? list,
    {String join = ", ", bool withParenthesis = true}) {
  return serializeListText(list?.map((e) => e.serialize()).toList(),
      withParenthesis: withParenthesis, join: join);
}

String serializeListText(List<String>? list,
    {String join = ", ", bool withParenthesis = true}) {
  if (list == null || list.isEmpty) {
    return '';
  }
  if (withParenthesis) {
    return "(${list.join(join)})";
  } else {
    return list.join(join);
  }
}
