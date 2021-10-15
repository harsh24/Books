import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireauth/repository/db.dart';
import 'package:fireauth/model/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:readmore/readmore.dart';
import 'package:intl/intl.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({Key? key, required this.book, this.fav})
      : super(key: key);
  final Book book;
  final String? fav;

  @override
  _BookDetailsPageState createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage>
    with TickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;
  late TabController _tabcontroller;
  int _selectedIndex = 0;
  String date = '';
  Future<QuerySnapshot<Object?>>? _fetch;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });

    _fetch = Database.isbnExists(isbn: widget.book.isbn13!);
    // fav = widget.fav != null ? true : false;

//Tab Controller
    _tabcontroller = TabController(length: 2, vsync: this);
    _tabcontroller.addListener(() {
      setState(() {
        _selectedIndex = _tabcontroller.index;
      });
    });

//Publish date Format
    String dateString = widget.book.publishedDate!;
    DateTime d;
    if (dateString.length == 4) {
      date = dateString;
    } else if (dateString.length == 7) {
      d = DateFormat("yyyy-mm").parse(dateString);
      date = DateFormat("MMMM yyyy").format(d);
    } else {
      d = DateFormat("yyyy-mm-dd").parse(dateString);
      date = DateFormat("d MMMM yyyy").format(d);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _tabcontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.book;
    _scale = 1 - _controller.value;

    return Scaffold(
      body: FutureBuilder(
          future: _fetch,
          builder: (context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            bool? fav;
            String? docid;

            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              final data = snapshot.data!;
              fav = data.size > 0 ? true : false;
              docid = fav ? data.docs[0].id : null;
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return Button(
              item: item,
              date: date,
              fav: fav!,
              docId: docid,
            );
          }),
    );
  }
}

class Button extends HookWidget {
  const Button(
      {Key? key,
      required this.item,
      required this.date,
      required this.fav,
      required this.docId})
      : super(key: key);

  final Book item;
  final String date;
  final bool fav;
  final String? docId;

  @override
  Widget build(BuildContext context) {
    final _controller = useAnimationController(
        duration: const Duration(seconds: 2), lowerBound: 0.0, upperBound: 0.1);
    double _scale = 1 - _controller.value;
    final _id = useState(docId);

    final _tabcontroller = useTabController(initialLength: 2);
    final _fav = useState(fav);
    final i = useState(0);
    final futures = useState(<Future>[]);

    return Center(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * .5,
            flexibleSpace: SizedBox(
              height: MediaQuery.of(context).size.height * .5,
              child: Stack(children: [
                Align(
                    alignment: Alignment.center,
                    child: TabBarView(controller: _tabcontroller, children: [
                      Image.network(item.thumbnailUrl ?? ''),
                      Center(
                          child: Text(
                        (item.pageCount != 'null'
                                ? (item.pageCount! + ' pages\n\n')
                                : '') +
                            (item.publishedDate != null
                                ? 'Published ' + date
                                : '') +
                            (item.publisher != null
                                ? '\nby ' + item.publisher!
                                : '') +
                            (item.isbn13 != null
                                ? '\n\nISBN: ' + item.isbn13!
                                : ''),
                        textAlign: TextAlign.center,
                      )),
                    ])),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (index) {
                        final _color = _tabcontroller.index == index
                            ? Colors.white
                            : Colors.grey;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: _color,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    SizedBox(
                      width: 250,
                      child: Text(
                        item.title ?? '',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ('by ' + (item.authors ?? 'Not available')),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                      child: Divider(
                        color: Colors.grey,
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  5,
                                  (int index) {
                                    if (item.averageRating != null) {
                                      return item.averageRating is double &&
                                              index !=
                                                  item.averageRating!.toInt()
                                          ? Icon(
                                              Icons.star,
                                              size: 16,
                                              color: index <
                                                      item.averageRating!
                                                          .toInt()
                                                  ? Colors.orange[700]
                                                  : Colors.grey[300],
                                            )
                                          : HalfFilledIcon(
                                              icon: Icons.star,
                                              color: Colors.orange[700]!,
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
                              item.averageRating?.toString() ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          ((item.ratingCount?.toString() ?? '0 ') +
                              ' ratings '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 12.0, 0, 12.0),
                      child: Divider(
                        color: Colors.grey,
                        indent: 20,
                        endIndent: 20,
                      ),
                    ),
                    Transform.scale(
                      scale: _scale,
                      child: ElevatedButton.icon(
                          onPressed: () async {
                            _fav.value
                                ? Database.deleteItem(docId: item.isbn13!)
                                : Database.addItem(isbn: item.isbn13!);

                            _fav.value = !_fav.value;
                            /*   _fav.value
                                ? _controller.reverse()
                                : _controller.forward(); */
                          },
                          icon: Icon(Icons.favorite,
                              color: _fav.value ? Colors.pink : Colors.white),
                          label: Text((_fav.value ? 'Added' : 'Add') +
                              ' to favorites')),
                    ),
                    item.description != null
                        ? Column(
                            children: [
                              Text(
                                'BOOK DESCRIPTION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                              const Divider(
                                color: Colors.black,
                                indent: 135,
                                endIndent: 135,
                              ),
                            ],
                          )
                        : Container(),
                    Container(
                      //height: MediaQuery.of(context).size.height * .2,
                      padding: const EdgeInsets.all(16.0),
                      child: ReadMoreText(
                        item.description ?? '',
                        trimLines: 10,
                        colorClickableText: Colors.deepOrange,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'read more',
                        trimExpandedText: 'read less',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HalfFilledIcon extends StatelessWidget {
  const HalfFilledIcon(
      {Key? key, required this.icon, required this.size, required this.color})
      : super(key: key);

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (Rect rect) {
        return LinearGradient(
          stops: const [0, 0.5, 0.5],
          colors: [color, color, color.withOpacity(0)],
        ).createShader(rect);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, size: size, color: Colors.grey[300]),
      ),
    );
  }
}
