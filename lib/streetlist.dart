import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StreetListPage extends StatefulWidget {
  const StreetListPage({super.key, required this.cityId});

  final int cityId;

  @override
  State<StreetListPage> createState() => _StreetListPageState();
}

class _StreetListPageState extends State<StreetListPage> {
  late Future<List<Street>> listOfStreets;
  //bool showAppbar = false;

  @override
  void initState() {
    super.initState();
    listOfStreets = getData(widget.cityId);
  }

  Future<List<Street>> getData(int cityId) async {
    final response = await http.get(Uri.parse(
        'https://649befbd0480757192372825.mockapi.io/api/v1/cities/$cityId/streets'));

    if (response.statusCode == 200) {
      String streetJson = response.body;

      return parseStreets(streetJson);
    }
    throw Exception('Failed to load streets');
  }

  List<Street> parseStreets(String streetJson) {
    var streetListJson = jsonDecode(streetJson) as List;
    List<Street> streetList =
        streetListJson.map((street) => Street.fromJson(street)).toList();

    return streetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: showAppbar
      //     ? (AppBar(
      //         shadowColor: Colors.white,
      //         elevation: 0,
      //         title: const Text(
      //           'Улицы города',
      //         ),
      //       ))
      //     : null,
      body: FutureBuilder<List>(
          future: listOfStreets,
          builder: ((context, snapshot) {
            Widget widget;
            List<Widget> children = [];
            if (snapshot.hasData) {
              children.add(AppBar(
                shadowColor: Colors.white,
                elevation: 0,
                title: const Text(
                  'Улицы города',
                ),
              ));
              for (var street in snapshot.data!) {
                children.add(street);
              }
              //showAppbar = true;
              widget = Center(child: Column(children: children));
            } else if (snapshot.hasError) {
              widget = Column(
                children: [
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Image.asset('assets/fail-streets.png'),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 24, 0, 4),
                    child: const Text('Без улиц можно потеряться'),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 116),
                    child: const Text(
                        '''Не смогли загрузить список улиц, спросите у кого‑нибудь как пройти'''),
                  ),
                  TextButton(
                      onPressed: (() => setState(() {})),
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text('Попробовать снова'))
                ],
              );
            } else {
              widget = Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 2),
                child: const Center(
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              child: widget,
            );
          })),
    );
  }
}

class Street extends StatelessWidget {
  final int id, cityId;
  final String name, address;

  const Street(
      {super.key,
      required this.id,
      required this.cityId,
      required this.name,
      required this.address});

  factory Street.fromJson(Map<String, dynamic> json) {
    return Street(
        id: int.parse(json['id']),
        cityId: int.parse(json['cityId']),
        name: json['name'],
        address: json['address']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 24, 8),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(
                  width: 1, color: Color.fromRGBO(234, 236, 240, 1)))),
      alignment: Alignment.centerLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          name,
          style: const TextStyle(
              fontSize: 18, color: Color.fromRGBO(13, 20, 33, 1)),
        ),
        Text(
          address,
          style: const TextStyle(
              fontSize: 16, color: Color.fromRGBO(102, 112, 133, 1)),
        )
      ]),
    );
  }
}
