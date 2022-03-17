import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:isar/isar.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:quotes/quote.dart';

class QuotesList extends StatefulWidget {
  final Isar isar;

  const QuotesList({Key? key, required this.isar}) : super(key: key);

  @override
  _QuotesListState createState() => _QuotesListState();
}

class _QuotesListState extends State<QuotesList> {
  final searchController = TextEditingController();

  List<Quote> quotes = [];
  bool hasMore = true;
  bool isLoading = true;
  String author = '';
  String searchTerm = '';
  int total = 0;

  @override
  void initState() {
    loadMore();
    searchController.addListener(() {
      loadMore(newSearchTerm: searchController.text);
    });
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Query<Quote> buildQuery({bool offsetLimit = false}) {
    final searchTermWords = searchTerm.split(RegExp(r'\s+'));
    return widget.isar.quotes
        .where()
        .repeat(
          searchTermWords,
          (q, String word) => q.optional(
            word.isNotEmpty,
            (q) => q.textWordsAnyStartsWith(word),
          ),
        )
        .filter()
        .optional(
          author.isNotEmpty,
          (q) => q.authorEqualTo(author),
        )
        .optional(offsetLimit, (q) => q.offset(quotes.length).limit(20))
        .build();
  }

  void loadMore({String? newSearchTerm, String? newAuthor}) async {
    setState(() {
      isLoading = true;
      if (newSearchTerm != null) {
        quotes = [];
        searchTerm = newSearchTerm;
      } else if (newAuthor != null) {
        quotes = [];
        author = newAuthor;
      }
    });

    final newQuotes = await buildQuery(offsetLimit: true).findAll();
    final newTotal = await buildQuery().count();

    setState(() {
      isLoading = false;
      quotes.addAll(newQuotes);
      hasMore = newTotal > quotes.length;
      total = newTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Search quote',
                    suffixIcon: IconButton(
                      onPressed: searchController.clear,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  await widget.isar.writeTxn((isar) async {
                    await buildQuery().deleteAll();
                  });
                  loadMore(newAuthor: author);
                },
                child: const Text('Drop results'),
              )
            ],
          ),
        ),
        if (author.isNotEmpty)
          Center(
            child: Chip(
              label: Text(author),
              deleteIcon: const Icon(Icons.clear),
              labelPadding: const EdgeInsets.all(6),
              onDeleted: () {
                loadMore(newAuthor: '');
              },
            ),
          )
        else
          const Center(
            child: Text('Tap author to filter'),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: LazyLoadScrollView(
              onEndOfPage: () {
                if (hasMore) {
                  loadMore();
                }
              },
              isLoading: isLoading,
              scrollOffset: 300,
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 10,
                itemCount: quotes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: index % 2 == 0
                        ? const EdgeInsets.only(left: 5)
                        : const EdgeInsets.only(right: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        AspectRatio(
                          aspectRatio: 1,
                          child: _buildQuote(context, quotes[index]),
                        ),
                      ],
                    ),
                  );
                },
                staggeredTileBuilder: (int index) => StaggeredTile.count(
                  5,
                  index == 1 ? 6 : 5,
                ),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: Center(child: Text('$total quotes')),
        )
      ],
    );
  }

  Widget _buildQuote(BuildContext context, Quote quote) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AutoSizeText(
                quote.text,
                minFontSize: 8,
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  loadMore(newAuthor: quote.author);
                },
                child: AutoSizeText(
                  quote.author,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
