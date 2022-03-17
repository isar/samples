import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'quote.dart';
import 'dart:developer';

class LoadQuotes extends StatefulWidget {
  final Isar isar;

  const LoadQuotes({Key? key, required this.isar}) : super(key: key);

  @override
  _LoadQuotesState createState() => _LoadQuotesState();
}

class _LoadQuotesState extends State<LoadQuotes> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Hey there!',
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          const SizedBox(
            width: 250,
            child: Text(
                'The quotes are not loaded yet. Do you load them from the assets?'),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: loadQuotes,
            child: const Text('Load Quotes!'),
          ),
          const SizedBox(height: 10),
          if (_error != null) Text(_error!),
        ],
      ),
    );
  }

  void loadQuotes() async {
    try {
      final bytes = await rootBundle.load('assets/quotes.json');
      final jsonStr = const Utf8Decoder().convert(bytes.buffer.asUint8List());
      final json = jsonDecode(jsonStr) as List;
      final quotes = json.map((e) => Quote()
        ..text = e['text']
        ..author = e['author']);
      widget.isar.writeTxn((isar) async {
        await isar.quotes.putAll(quotes.toList());
      });
    } catch (e) {
      log("ERROR: $e");
      setState(() {
        _error = e.toString();
      });
    }
  }
}
