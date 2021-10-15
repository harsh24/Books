import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireauth/screens/book_detail_page.dart';
import 'package:fireauth/repository/db.dart';
import 'package:fireauth/model/jsonresponse.dart';
import 'package:fireauth/model/book.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late Future<QuerySnapshot<Object?>> _fetch;

  List<String> b = [];
  List<String> bid = [];
  List<Book> items = [];
  final AsyncMemoizer<List<Book>> _memoizer = AsyncMemoizer();

  @override
  void initState() {
    _fetch = Database.readItems();

    super.initState();
  }

  Future<List<Book>> _fetchPotterBooks(List<String> url) async {
    return _memoizer.runOnce(() async {
      List<Book> _book = [];
      for (int i = 0; i < url.length; i++) {
        final uri = Uri.https('books.googleapis.com', '/books/v1/volumes', {
          'q': 'isbn:' + url[i],
          // 'key': 'AIzaSyC0Ic8WDdYc6uzNbsGj_YrM0ShItExdlxw',
        });
        final res = await http.get(uri);
        if (res.statusCode == 200) {
          _book.add(_parseBookJson(res.body));
        } else {
          throw Exception('Error: ${res.statusCode}');
        }
      }

      return _book;
    });
  }

  Book _parseBookJson(String jsonStr) {
    final jsonMap = json.decode(jsonStr);

    if (jsonMap['totalItems'] != 0) {
      final volume = VolumeJson.fromJson(jsonMap);
      var formatter = NumberFormat('#,##,##0');

      final x = volume.items
          .map((result) => Book(
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
              ))
          .toList();

      return x[0];
    }
    return Book(totalItems: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder<QuerySnapshot>(
            future: _fetch,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.done) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasData) {
                /* final x = snapshot.data!.docs.map((element) {
                  /* Map<String, dynamic> data =
                      element.data()! as Map<String, dynamic>; */
                  print(element['isbn']);
                  return b?.add(element['isbn']);
                }).toList(); */
                Map<String, dynamic> data;
                final element = snapshot.data!;
                for (int i = 0; i < element.size; i++) {
                  data = snapshot.data!.docs[i].data()! as Map<String, dynamic>;
                  b.add(data['isbn']);
                  bid.add(element.docs[i].id);
                }
              }
              return FutureBuilder<List<Book>>(
                  future: _fetchPotterBooks(b),
                  builder: (context, snapshot) {
                    // if (snapshot.connectionState == ConnectionState.done) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasData) {
                      items = snapshot.data!;
                    }
                    return
                        //onTap: () => _navigateToDetailsPage(b, context),
                        ListView.separated(
                      key: UniqueKey(),
                      separatorBuilder: (context, index) {
                        return Divider(
                          indent: 12,
                          color: Colors.grey[400],
                        );
                      },
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final item = snapshot.data![index];
                        return item.totalItems != 0
                            ? Dismissible(
                                key: UniqueKey(),
                                confirmDismiss:
                                    (DismissDirection direction) async {
                                  return await showDialog(
                                      context: context,
                                      builder:
                                          (BuildContext context) => AlertDialog(
                                                buttonPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 8, 40, 8),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0)),
                                                title: Text(item.title!),
                                                content: const Text(
                                                    'Are you sure you want to delete ?'),
                                                actions: [
                                                  TextButton(
                                                    style: ButtonStyle(
                                                      shape: MaterialStateProperty.all(
                                                          RoundedRectangleBorder(
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          32.0))),
                                                    ),
                                                    child: const Text(
                                                      'No',
                                                      style: TextStyle(
                                                          color: Colors.grey),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  TextButton(
                                                    style: ButtonStyle(
                                                      shape: MaterialStateProperty.all(
                                                          RoundedRectangleBorder(
                                                              side: const BorderSide(
                                                                  color: Colors
                                                                      .red),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30.0))),
                                                    ),
                                                    child: const Text(
                                                      'Yes',
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                    onPressed: () async {
                                                      await Database.deleteItem(
                                                          docId: bid[index]);
                                                      return Navigator.pop(
                                                          context, true);
                                                    },
                                                  ),
                                                ],
                                              ));
                                },
                                background: Container(color: Colors.red),
                                onDismissed: (direction) async {
                                  setState(() {
                                    snapshot.data!.removeAt(index);
                                  });
                                },
                                child: ListTile(
                                  key: UniqueKey(),
                                  isThreeLine: true,
                                  onTap: () =>
                                      _navigateToDetailsPage(item, context),
                                  leading: AspectRatio(
                                    aspectRatio: 1,
                                    child: item.thumbnailUrl != null
                                        ? Image.network(item.thumbnailUrl!)
                                        : const FlutterLogo(),
                                  ),
                                  title: Text(item.title ?? ''),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child:
                                            Text('by ' + (item.authors ?? '')),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Row(
                                                    children: List.generate(
                                                  5,
                                                  (int index) {
                                                    if (item.averageRating !=
                                                        null) {
                                                      return item.averageRating
                                                                  is double &&
                                                              index !=
                                                                  item.averageRating!
                                                                      .toInt()
                                                          ? Icon(
                                                              Icons.star,
                                                              size: 16,
                                                              color: index <
                                                                      item.averageRating!
                                                                          .toInt()
                                                                  ? Colors.orange[
                                                                      700]
                                                                  : Colors.grey[
                                                                      300],
                                                            )
                                                          : HalfFilledIcon(
                                                              icon: Icons.star,
                                                              color: Colors
                                                                  .orange[700]!,
                                                              size: 16,
                                                            );
                                                    } else {
                                                      return Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Colors.grey[300],
                                                      );
                                                    }
                                                  },
                                                )),
                                                const SizedBox(width: 8),
                                                Text(
                                                  item.averageRating
                                                          ?.toString() ??
                                                      '    ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              ((item.ratingCount?.toString() ??
                                                      '0 ') +
                                                  ' ratings '),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const Center(child: Text('a'));
                      },
                    );
                  });
            }));
  }

  Future<void> _navigateToDetailsPage(Book book, BuildContext context) async {
    /* final QuerySnapshot<Object?> x =
        await Database.isbnExists(isbn: book.isbn!); */
    //final _fav = x.size > 0 ? x.docs[0].id : null;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BookDetailsPage(
        book: book,
        fav: '',
      ),
    ));
  }
}
