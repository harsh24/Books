import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireauth/screens/book_detail_page.dart';
import 'package:fireauth/widget/booklistwidget.dart';
import 'package:fireauth/repository/db.dart';
import 'package:fireauth/model/jsonresponse.dart';
import 'package:fireauth/model/book.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const url1 =
    'https://www.googleapis.com/books/v1/volumes?q=harry+potter+inauthor:rowling';
const url2 = 'https://www.googleapis.com/books/v1/volumes?q=Twilight';

class BookFinderPage extends StatefulWidget {
  const BookFinderPage({Key? key}) : super(key: key);

  @override
  State<BookFinderPage> createState() => _BookFinderPageState();
}

class _BookFinderPageState extends State<BookFinderPage> {
  List<Book> _results = [];
  Future<List<Book>>? _fetch;
  bool isLoading = true;
  final textcontroller = TextEditingController();

  @override
  void initState() {
    _fetch = _fetchPotterBooks('twilight', '0', '10');
    super.initState();
  }

  @override
  void dispose() {
    textcontroller.dispose();
    super.dispose();
  }

  Timer? searchOnStoppedTyping;

  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
            500); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
        () => searchOnStoppedTyping = Timer(duration, () => search(value)));
  }

  search(String value) async {
    List<Book> result = [];
    if (value.isNotEmpty) {
      result = await _fetchPotterBooks(value, '0', '4');
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _results = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Book>? items;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, top: 32, bottom: 16),
                child: Text(
                  'Explore thousands of\nbooks on the go',
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: 'Mollen',
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/fav');
                  },
                  icon: const Icon(Icons.favorite_border))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: TextField(
                  controller: textcontroller,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search for books...'),
                  onChanged:
                      _onChangeHandler /* (v) async {
                  final result = await _fetchPotterBooks(textcontroller.text);
                  setState(() {
                    _results = result;
                  });
                  //_results = results.toDomain();
                }, */
                  ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _results.isNotEmpty
                  ? Column(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          key: UniqueKey(),
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            return item.totalItems != 0
                                ? ListTile(
                                    key: UniqueKey(),
                                    onTap: () => Navigator.of(context)
                                        .pushNamed('/detail',
                                            arguments: {'book': item}),
                                    // _navigateToDetailsPage(item, context),
                                    leading: AspectRatio(
                                      aspectRatio: 1,
                                      child: item.thumbnailUrl != null
                                          ? Image.network(item.thumbnailUrl!)
                                          : const FlutterLogo(),
                                    ),
                                    title: Text(item.title ?? ''),
                                    subtitle:
                                        Text('by ' + (item.authors ?? '')),
                                  )
                                : Center(
                                    child: Text('0 results for ' +
                                        textcontroller.text));
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pushNamed(context, '/results',
                                  arguments: {'results': _results});
                              /*   setState(() {
                                isLoading = !isLoading;
                              });
                              final _fetch = await _fetchPotterBooks(
                                  textcontroller.text, '10');
                              for (int i = 0; i < _fetch.length; i++) {
                                _results.add(_fetch[i]);
                              }
                              setState(() {
                                _results = _results;
                              });
                              setState(() {
                                isLoading = !isLoading;
                              }); */
                            },
                            child: Text(
                                'See all results for "${textcontroller.text}"'),
                          ),
                        )
                      ],
                    )
                  : FutureBuilder(
                      future: _fetch,
                      builder: (context, AsyncSnapshot<List<Book>> snapshot) {
                        // if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done) {
                          items = snapshot.data;
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, top: 16),
                              child: Text(
                                'Famous Books',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Mollen',
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                  children: items!
                                      .map((b) => GestureDetector(
                                            onTap: () => Navigator.of(context)
                                                .pushNamed('/detail',
                                                    arguments: {'book': b}),
                                            child: BookListWidget(
                                              book: b,
                                            ),
                                          ))
                                      .toList()),
                            ),
                          ],
                        );
                      }),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<Book>> _fetchPotterBooks(
    String url, String index, String max) async {
  print('object');
  final uri = Uri.https('books.googleapis.com', '/books/v1/volumes', {
    'q': url,
    'startIndex': index,
    'maxResults': max,
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
            ratingCount: formatter.format(result.volumeinfo.ratingsCount ?? 0),
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

Future<void> _navigateToDetailsPage(Book book, BuildContext context) async {
  final QuerySnapshot<Object?> x =
      await Database.isbnExists(isbn: book.isbn13!);
  final _fav = x.size > 0 ? x.docs[0].id : null;
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => BookDetailsPage(
      book: book,
      fav: _fav,
    ),
  ));
}
