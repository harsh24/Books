import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireauth/screens/book_detail_page.dart';
import 'package:fireauth/repository/db.dart';
import 'package:fireauth/model/book.dart';
import 'package:fireauth/service/google_books_service.dart';
import 'package:fireauth/service/profile_provider.dart';
import 'package:fireauth/service/responsive.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';

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

  Future<List<Book>> _favourites(List<String> url) async {
    return _memoizer.runOnce(() async {
      GoogleBooksService googleBooksService = GoogleBooksService();
      List<Book> _book = [];
      for (int i = 0; i < url.length; i++) {
        _book.add((await googleBooksService.getBooks(
            '', '0', '1', 'isbn:' + url[i]))[0]);
      }

      return _book;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _imagesize = 200;
    double _fontsize = 20;
    double _screenwidth = _size.width;
    if (ResponsiveWidget.isLargeScreen(context)) {
      _imagesize = 400;
      _fontsize = 30;
      _screenwidth = _size.width / 3;
    }

    return Scaffold(
      //extendBodyBehindAppBar: true,
      appBar: ResponsiveWidget.isLargeScreen(context)
          ? PreferredSize(
              preferredSize: Size(_size.width, _size.height / 6),
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'My Books',
                  style: TextStyle(fontSize: 60),
                ),
              ))
          : AppBar(
              title: const Text('My Books'),
            ),
      body: Center(
        child: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return !profileProvider.isAuthentificated
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Track and store your books\n you want to read.',
                        style: TextStyle(fontSize: _fontsize),
                      ),
                      FittedBox(
                        child: SizedBox(
                          height: _imagesize,
                          child: Image.asset(
                            'assets/images/books.png',
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pushNamed(
                                  context, '/auth',
                                  arguments: {'type': true}),
                              style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(220, 10),
                                  primary: Colors.indigo),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already a member? ',
                                style: TextStyle(fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/auth',
                                    arguments: {'type': false},
                                  );
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.teal,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  )
                : SizedBox(
                    width: _screenwidth,
                    child: FutureBuilder<QuerySnapshot>(
                      future: _fetch,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasData) {
                          Map<String, dynamic> data;
                          final element = snapshot.data!;
                          for (int i = 0; i < element.size; i++) {
                            data = snapshot.data!.docs[i].data()!
                                as Map<String, dynamic>;
                            b.add(data['isbn']);
                            bid.add(element.docs[i].id);
                          }
                        }
                        return FutureBuilder<List<Book>>(
                          future: _favourites(b),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasData) {
                              items = snapshot.data!;
                            }
                            return ListView.separated(
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
                                        direction: DismissDirection.endToStart,
                                        confirmDismiss:
                                            (DismissDirection direction) async {
                                          return await showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    buttonPadding:
                                                        const EdgeInsets
                                                                .fromLTRB(
                                                            0, 8, 40, 8),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0)),
                                                    title: Text(item.title!),
                                                    content: const Text(
                                                        'Are you sure you want to delete ?'),
                                                    actions: [
                                                      TextButton(
                                                        style: ButtonStyle(
                                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
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
                                                              color:
                                                                  Colors.grey),
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
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () async {
                                                          await Database
                                                              .deleteItem(
                                                                  docId: bid[
                                                                      index]);
                                                          return Navigator.pop(
                                                              context, true);
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        background:
                                            Container(color: Colors.red),
                                        onDismissed: (direction) async {
                                          setState(() {
                                            snapshot.data!.removeAt(index);
                                          });
                                        },
                                        child: ListTile(
                                          key: UniqueKey(),
                                          isThreeLine: true,
                                          onTap: () => Navigator.of(context)
                                              .pushNamed('/detail',
                                                  arguments: {'book': item}),
                                          leading: AspectRatio(
                                            aspectRatio: 1,
                                            child: item.thumbnailUrl != null
                                                ? Image.network(
                                                    item.thumbnailUrl!)
                                                : const FlutterLogo(),
                                          ),
                                          title: Text(item.title ?? ''),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.0),
                                                child: Text('by ' +
                                                    (item.authors ?? '')),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2.0),
                                                child: Row(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Row(
                                                            children:
                                                                List.generate(
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
                                                                      Icons
                                                                          .star,
                                                                      size: 16,
                                                                      color: index <
                                                                              item.averageRating!
                                                                                  .toInt()
                                                                          ? Colors.orange[
                                                                              700]
                                                                          : Colors
                                                                              .grey[300],
                                                                    )
                                                                  : HalfFilledIcon(
                                                                      icon: Icons
                                                                          .star,
                                                                      color: Colors
                                                                              .orange[
                                                                          700]!,
                                                                      size: 16,
                                                                    );
                                                            } else {
                                                              return Icon(
                                                                Icons.star,
                                                                size: 16,
                                                                color: Colors
                                                                    .grey[300],
                                                              );
                                                            }
                                                          },
                                                        )),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                          item.averageRating
                                                                  ?.toString() ??
                                                              '    ',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Text(
                                                      ((item.ratingCount
                                                                  ?.toString() ??
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
                          },
                        );
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }
}
