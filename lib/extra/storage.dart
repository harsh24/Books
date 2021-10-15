/* import 'package:fireauth/db.dart';
import 'package:fireauth/model/book.dart';

class Storage {
  Future<List<Book>>? retrievetable() {
    final objects = Database.readItems();
    return objects.map((map) => Book().fromMap(map)).toList();
  }
}
 */