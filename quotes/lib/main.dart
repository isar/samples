import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quotes/load_quotes.dart';
import 'package:quotes/quote.dart';
import 'package:quotes/quotes_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = !kIsWeb ? (await getApplicationDocumentsDirectory()).path : null;
  final isar = await Isar.open(
    schemas: [QuoteSchema],
    directory: path,
    inspector: true
  );
  runApp(QuotesApp(
    isar: isar,
  ));
}

class QuotesApp extends StatelessWidget {
  final Isar isar;

  const QuotesApp({Key? key, required this.isar}) : super(key: key);
  Stream<List<Quote>> execQuery() {
    return isar.quotes.where().limit(1).build().watch(initialReturn: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: StreamBuilder(
            stream: execQuery(),
            builder: (context, AsyncSnapshot<List<Quote>?> data) {
              if (data.hasData) {
                if (data.data!.isEmpty) {
                  return LoadQuotes(isar: isar);
                } else {
                  return QuotesList(
                    isar: isar,
                  );
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
