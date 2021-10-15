import 'dart:convert';

import 'package:fireauth/model/book.dart';
import 'package:fireauth/model/jsonresponse.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

class GoogleBooksService {
  Future<List<Book>> getBooks(String url, String index) async {
    final uri = Uri.https('books.googleapis.com', '/books/v1/volumes', {
      'q': url,
      'startIndex': index,
    });
    print(uri.toString());

    final res = await get(uri);

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

      return x;
    }
    return [Book(totalItems: 0)];
  }
}
