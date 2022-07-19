class GQSchema {
  final String query;
  final String mutation;
  final String subscription;

  GQSchema({
    this.query = "Query",
    this.mutation = "Mutation",
    this.subscription = "Subscription",
  });

  factory GQSchema.fromList(List<String> list) {
    String query = find("query", list) ?? "Query";
    String mutation = find("mutation", list) ?? "Mutation";
    String subscription = find("subscription", list) ?? "Subscription";
    return GQSchema(
        query: query, mutation: mutation, subscription: subscription);
  }

  static String? find(String prefix, List<String> list) {
    var elem = list.where((element) => element.startsWith(prefix)).toList();
    return elem.isEmpty ? null : elem.first.split("-")[1].trim();
  }

  static GQSchema defaultSchema() => GQSchema();
}
