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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new FutureBuilder(
      future: getData(),
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
      title: 'Minha lista de fotos',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Minha lista de fotos'),
        ),
        body: futureBuilder,
      ),
    );
  }
}

Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
  List<Photo> photos = snapshot.data;
  return ListView.builder(
    itemCount: photos.length,
    cacheExtent: 10.0,
    itemBuilder: (BuildContext context, int index) {
      return Column(children: [
        ListTile(
          title: Text(photos[index].title),
          leading: Image.network(photos[index].urlImage.toString()),
          subtitle: Text("#${photos[index].id}"),
        ),
        Divider(height: 2.0)
      ],
      );
    },
    );
}

Future<List<Photo>> getData() async {
  List<Photo> values = [];

final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));

  if (response.statusCode == 200) {
    List<Photo> photos = (json.decode(response.body) as List)
      .map((data) => Photo.fromJson(data))
      .toList();
   values.addAll(photos);
  } else {
    throw Exception('Failed to load photos');
  }
  return values;
}

class Photo {
  final int id;
  final String title;
  final String urlImage;

  Photo({
    required this.id,
    required this.title,
    required this.urlImage,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      title: json['title'],
      urlImage: json['thumbnailUrl'],
    );
  }
}
