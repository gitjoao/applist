import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Album> futureAlbum;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: _getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return new Text("nada");
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            if (snapshot.hasError) {
              return Text("erro");
            } else {
              return createListView(context, snapshot);
            }
        }
      },
    );

    return MaterialApp(
      title: 'A tal da lista infinita',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('A tal da lista infinita'),
        ),
        body: futureBuilder,
      ),
    );
  }
}

Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
  List<Album> values = snapshot.data;
  return ListView.builder(
    itemCount: values.length,
    cacheExtent: 10.0,
    itemBuilder: (BuildContext context, int index) {
      return Column(children: [
        ListTile(
          title: Text(values[index].title),
          leading: Image.network(values[index].urlImage.toString()),
          subtitle: Text("#${values[index].id}"),
        ),
        Divider(height: 2.0)
      ],
      );
    },
    );
}

Future<List<Album>> _getData() async {
  List<Album> values = [];

final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

  if (response.statusCode == 200) {
    List<Album> photos = (json.decode(response.body) as List)
      .map((data) => Album.fromJson(data))
      .toList();
   values.addAll(photos);
  } else {
    throw Exception('Failed to load album');
  }
  return values;
}

class Album {
  final int id;
  final String title;
  final String urlImage;

  Album({
    required this.id,
    required this.title,
    required this.urlImage,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
      urlImage: json['thumbnailUrl'],
    );
  }
}
