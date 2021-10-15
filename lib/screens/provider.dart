import 'package:fireauth/model/book.dart';
import 'package:fireauth/model/jsonresponse.dart';
import 'package:fireauth/screens/google_books_service.dart';
import 'package:flutter/material.dart';

class GBookProvider with ChangeNotifier {
  GoogleBooksService googleBooksService = GoogleBooksService();

  List<Book>? _item;
  List<Book>? get bookItem => _item;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /*  GBookProvider(String query) {
    googleBooksService = GoogleBooksService();
    getResults(query);
  } */

  void getResults(String url, String index) async {
    setLoading(true);
    _item = await googleBooksService.getBooks(url, index);
    setLoading(false);
  }

  void setLoading(bool b) {
    _isLoading = b;
    notifyListeners();
  }

  void clearBook() {
    _item = null;
  }
}
