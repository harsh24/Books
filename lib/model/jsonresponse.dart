class VolumeJson {
  final int totalItems;

  final String? kind;

  final List<Item> items;

  VolumeJson(
      {required this.items, required this.kind, required this.totalItems});

  factory VolumeJson.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['items'] as List;

    List<Item> itemList = list.map((i) {
      return Item.fromJson(i);
    }).toList();

    return VolumeJson(
        items: itemList,
        kind: parsedJson['kind'] as String?,
        totalItems: parsedJson['totalItems']);
  }
}

class Item {
  final String? kind;

  final String? etag;

  final VolumeInfo volumeinfo;

  Item({required this.kind, required this.etag, required this.volumeinfo});

  factory Item.fromJson(Map<String, dynamic> parsedJson) {
    return Item(
        kind: parsedJson['kind'] as String?,
        etag: parsedJson['etag'] as String?,
        volumeinfo: VolumeInfo.fromJson(parsedJson['volumeInfo']));
  }
}

class VolumeInfo {
  VolumeInfo({
    required this.printType,
    required this.title,
    required this.isbn,
    required this.publisher,
    required this.authors,
    required this.categories,
    required this.averageRating,
    required this.image,
    required this.ratingsCount,
    required this.description,
    required this.pageCount,
    required this.publishedDate,
  });

  final String? title;
  final String? publisher;
  final String? printType;
  final String? authors;
  final String? categories;
  final String? description;
  final String? publishedDate;

  final dynamic averageRating;
  final ImageLinks? image;
  final List<ISBN>? isbn;
  final int? ratingsCount;
  final int? pageCount;

  factory VolumeInfo.fromJson(Map<String, dynamic> parsedJson) {
    //print('GETTING DATA');
    //print(isbnList[1]);
    var list = parsedJson['industryIdentifiers'] as List;
    List<ISBN> isbn = list.map((i) => ISBN.fromJson(i)).toList();

    return VolumeInfo(
      title: parsedJson['title'] as String?,
      publisher: parsedJson['publisher'] as String?,
      publishedDate: parsedJson['publishedDate'] as String?,
      printType: parsedJson['printType'] as String?,
      authors: (parsedJson['authors'])?.join(', '),
      categories: (parsedJson['categories'])?.join(', '),
      averageRating: parsedJson['averageRating'],
      pageCount: parsedJson['pageCount'],
      ratingsCount: parsedJson['ratingsCount'],
      description: parsedJson['description'],
      isbn: isbn,
      image: ImageLinks?.fromJson(
          parsedJson['imageLinks'] as Map<String, dynamic>?),
    );
  }
}

class ImageLinks {
  final String? thumb;

  ImageLinks({this.thumb});

  factory ImageLinks.fromJson(Map<String, dynamic>? parsedJson) {
    return ImageLinks(thumb: parsedJson?['smallThumbnail'] as String?);
  }
}

class ISBN {
  final String iSBN13;
  final String type;

  ISBN({required this.iSBN13, required this.type});

  factory ISBN.fromJson(Map<String, dynamic>? parsedJson) {
    return ISBN(
      iSBN13: parsedJson?['identifier'],
      type: parsedJson?['type'],
    );
  }
}
