import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _mainCollection = _firestore.collection('book');

class Database {
  static String? userUid;

  static Future<String> addItem({
    required String isbn,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userUid).collection('items').doc(isbn);

    Map<String, dynamic> data = <String, dynamic>{
      "isbn": isbn,
    };
    await documentReferencer
        .set(data)
        .catchError((e) {
          //print(e);
        });
    return documentReferencer.id;
  }

  static Future<QuerySnapshot<Object?>> readItems() async {
    CollectionReference collectionReferencer =
        _mainCollection.doc(userUid).collection('items');

    return await collectionReferencer.get();
  }

  static Future<void> deleteItem({
    required String docId,
  }) async {
    DocumentReference documentReferencer =
        _mainCollection.doc(userUid).collection('items').doc(docId);
    await documentReferencer
        .delete()
        .catchError((e) {
         // print(e);
        });
  }

  static Future<QuerySnapshot<Object?>> isbnExists({
    required String isbn,
  }) async {
    CollectionReference collectionReferencer =
        _mainCollection.doc(userUid).collection('items');

    return await collectionReferencer
        .where('isbn', isEqualTo: isbn)
        .get()
        //.whenComplete(() async => print('yes'))
        .catchError((e) {
         // print(e);
        });
  }
}
