import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: Search()),
          ),
        ],
      ),
    );
  }
}

class Search extends SearchDelegate<String> {
  List<String> city = ['a', 'b', 'x'];
  List<String> rec = [];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final s = query.isEmpty
        ? rec
        : city.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
        itemCount: s.length,
        itemBuilder: (context, index) => ListTile(
              onTap: () => showResults(context),
              leading: Icon(Icons.location_city),
              title: Text(s[index]),
            ));
  }
}
