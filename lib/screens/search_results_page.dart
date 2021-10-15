import 'dart:convert';

import 'package:fireauth/model/book.dart';
import 'package:fireauth/model/jsonresponse.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({Key? key, required this.results}) : super(key: key);
  final List<Book> results;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider();
              },
              itemCount: widget.results.length + 1,
              itemBuilder: (context, index) {
                Book item = Book();
                if (index != widget.results.length) {
                  item = widget.results[index];
                }
                return item.totalItems != 0
                    ? index != widget.results.length
                        ? (ListTile(
                            key: UniqueKey(),
                            onTap: () => Navigator.of(context).pushNamed(
                                '/detail',
                                arguments: {'book': item}),
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: item.thumbnailUrl != null
                                  ? Image.network(item.thumbnailUrl!)
                                  : const FlutterLogo(),
                            ),
                            title: Text(item.title ?? ''),
                            subtitle: Text('by ' + (item.authors ?? '')),
                          ))
                        : isLoading
                            ? (ListTile(
                                title: const Center(
                                    child: Text('See more books...')),
                                onTap: () async {
                                  setState(() {
                                    isLoading = !isLoading;
                                  });
                                  final _fetch =
                                      await _fetchPotterBooks('harry', '10');
                                  for (int i = 0; i < _fetch.length; i++) {
                                    setState(() {
                                      widget.results.add(_fetch[i]);
                                    });
                                  }
                                  setState(() {
                                    isLoading = !isLoading;
                                  });
                                },
                              ))
                            : const Center(child: CircularProgressIndicator())
                    : const Center(child: Text('0 results for '));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Book>> _fetchPotterBooks(String url, String index) async {
    final uri = Uri.https('books.googleapis.com', '/books/v1/volumes', {
      'q': url,
      'startIndex': index,
      //'key': 'AIzaSyC0Ic8WDdYc6uzNbsGj_YrM0ShItExdlxw',
    });
    print(uri.toString());
    /* final uri = Uri.parse(
      'https://books.googleapis.com/books/v1/volumes?q=The%20ex%20hex&key=AIzaSyC0Ic8WDdYc6uzNbsGj_YrM0ShItExdlxw'); */
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      return _parseBookJson(res.body);
    } else {
      throw Exception('Error: ${res.statusCode}');
    }
  }

  List<Book> _parseBookJson(String jsonStr) {
    final jsonMap = json.decode(jsonStr);

    if (jsonMap['totalItems'] != 0) {
      final volume = VolumeJson.fromJson(jsonMap);
      var formatter = NumberFormat('#,##,##0');

      final x = volume.items
          .map(
            (result) => Book(
              title: result.volumeinfo.title,
              authors: result.volumeinfo.authors,
              thumbnailUrl: result.volumeinfo.image?.thumb,
              averageRating: result.volumeinfo.averageRating?.toDouble(),
              categories: result.volumeinfo.categories,
              isbn13: result.volumeinfo.isbn?[0].iSBN13,
              description: result.volumeinfo.description,
              ratingCount:
                  formatter.format(result.volumeinfo.ratingsCount ?? 0),
              pageCount: result.volumeinfo.pageCount.toString(),
              publishedDate: result.volumeinfo.publishedDate,
              publisher: result.volumeinfo.publisher,
            ),
          )
          .toList();
      /* final x = jsonList.map((jsonBook) {
    return Book(
      title: jsonBook['volumeInfo']['title'],
      //author: (jsonBook['volumeInfo']['authors'] as List).join(', '),
      /* thumbnailUrl:
          jsonBook['volumeInfo']['imageLinks']['smallThumbnail'] as String?, */
    );
  }).toList(); */
      return x;
    }
    return [Book(totalItems: 0)];
  }
}
