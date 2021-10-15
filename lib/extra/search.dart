import 'package:flutter/material.dart';

class SearchList extends StatefulWidget {
  SearchList({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  _SearchListState createState() => new _SearchListState();
}

class _SearchListState extends State<SearchList> {
  Widget appBarTitle = const Text(
    "",
    style: TextStyle(color: Colors.white),
  );
  Icon actionIcon = const Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  List<SearchResult> _list = [];
  bool? _IsSearching;
  String _searchText = "";
  String selectedSearchValue = "";

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    createSearchResultList();
  }

  void createSearchResultList() {
    _list = <SearchResult>[
      SearchResult(name: 'Google'),
      SearchResult(name: 'IOS'),
      SearchResult(name: 'IOS2'),
      SearchResult(name: 'Android'),
      SearchResult(name: 'Dart'),
      SearchResult(name: 'Flutter'),
      SearchResult(name: 'Python'),
      SearchResult(name: 'React'),
      SearchResult(name: 'Xamarin'),
      SearchResult(name: 'Kotlin'),
      SearchResult(name: 'RxAndroid'),
      SearchResult(name: 'Java'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: key,
        appBar: buildBar(context),
        body: Stack(
          children: <Widget>[
            Container(
              height: 300.0,
              padding: EdgeInsets.all(10.0),
              child: Container(
                child: ListView(
                  children: const <Widget>[
                    Text("Hello World!"),
                    Text("Hello World!"),
                    Text("Hello World!"),
                    Text("Hello World!"),
                    Text("Hello World!"),
                    Text("Hello World!"),
                    Text("Hello World!"),
                    Text("Hello World!"),
                  ],
                ),
              ),
            ),
            displaySearchResults(),
          ],
        ));
  }

  Widget displaySearchResults() {
    if (_IsSearching!) {
      return new Align(alignment: Alignment.topCenter, child: searchList());
    } else {
      return new Align(alignment: Alignment.topCenter, child: new Container());
    }
  }

  ListView searchList() {
    List<SearchResult> results = _buildSearchList();
    return ListView.builder(
      itemCount: _buildSearchList().isEmpty == null ? 0 : results.length,
      itemBuilder: (context, int index) {
        return Container(
          decoration: new BoxDecoration(
              color: Colors.grey[100],
              border: new Border(
                  bottom: new BorderSide(color: Colors.grey, width: 0.5))),
          child: ListTile(
            onTap: () {},
            title: Text(results.elementAt(index).name,
                style: new TextStyle(fontSize: 18.0)),
          ),
        );
      },
    );
  }

  List<SearchResult> _buildList() {
    return _list.map((result) => new SearchResult(name: result.name)).toList();
  }

  List<SearchResult> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _list
          .map((result) => new SearchResult(name: result.name))
          .toList();
    } else {
      List<SearchResult> _searchList = [];
      for (int i = 0; i < _list.length; i++) {
        SearchResult result = _list.elementAt(i);
        if ((result.name).toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(result);
        }
      }
      return _searchList
          .map((result) => new SearchResult(name: result.name))
          .toList();
    }
  }

  PreferredSizeWidget buildBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: appBarTitle,
      actions: <Widget>[
        IconButton(
          icon: actionIcon,
          onPressed: () {
            _displayTextField();
          },
        ),

        // new IconButton(icon: new Icon(Icons.more), onPressed: _IsSearching ? _showDialog(context, _buildSearchList()) : _showDialog(context,_buildList()))
      ],
    );
  }

  String selectedPopupRoute = "My Home";
  final List<String> popupRoutes = <String>[
    "My Home",
    "Favorite Room 1",
    "Favorite Room 2"
  ];

  void _displayTextField() {
    setState(() {
      if (this.actionIcon.icon == Icons.search) {
        this.actionIcon = new Icon(
          Icons.close,
          color: Colors.white,
        );
        this.appBarTitle = new TextField(
          autofocus: true,
          controller: _searchQuery,
          style: new TextStyle(
            color: Colors.white,
          ),
        );

        _handleSearchStart();
      } else {
        _handleSearchEnd();
      }
    });
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "",
        style: new TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }
}

class SearchResult {
  final String name;

  SearchResult({required this.name});
}
