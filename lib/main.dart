import 'package:flutter/material.dart';
import 'package:parser/graphql_parser/gq_grammar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parser test"),
      ),
      body: Center(
        child: TextButton(
          child: const Text("TEST"),
          onPressed: () {
            var g = GraphQlGrammar();

            var praser = g.start();

            praser.parse('''"test"''');
          },
        ),
      ),
    );
  }
}
