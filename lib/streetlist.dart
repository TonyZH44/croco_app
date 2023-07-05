import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'errorscreen.dart';
import 'package:http/http.dart' as http;

class StreetListPage extends StatefulWidget {
  const StreetListPage({super.key, required this.cityId});

  final int cityId;

  @override
  State<StreetListPage> createState() => _StreetListPageState();
}

class _StreetListPageState extends State<StreetListPage> {
  late Future<List<Street>> listOfStreets;

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
      //String empty = '[]';
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
    int cityId = widget.cityId;
    return FutureBuilder<List>(
        future: listOfStreets,
        builder: ((context, snapshot) {
          Widget widget;
          List<Widget> children = [];
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // children.add(AppBar(
            //   systemOverlayStyle:
            //       const SystemUiOverlayStyle(statusBarColor: Colors.white),
            //   shadowColor: Colors.white,
            //   elevation: 0,
            //   title: const Text(
            //     'Улицы города',
            //   ),
            // ));
            for (var street in snapshot.data!) {
              children.add(street);
            }
            widget = Scaffold(
                appBar: AppBar(
                  systemOverlayStyle:
                      const SystemUiOverlayStyle(statusBarColor: Colors.white),
                  shadowColor: Colors.white,
                  elevation: 0,
                  title: const Text(
                    'Улицы города',
                  ),
                ),
                body: SingleChildScrollView(child: Column(children: children)));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            widget = Scaffold(
              body: ErrorScreen(
                parent: StreetListPage(cityId: cityId),
                imageUrl: 'assets/no-streets.png',
                headerText: 'Тут пусто...',
                supportText: 'Названия улиц в этом городе ещё не добавлены',
                buttonText: 'Вернуться назад',
                goBack: true,
              ),
            );
          } else if (snapshot.hasError) {
            widget = Scaffold(
              body: ErrorScreen(
                parent: StreetListPage(cityId: cityId),
                imageUrl: 'assets/fail-streets.png',
                headerText: 'Без улиц можно потеряться',
                supportText:
                    'Не смогли загрузить список улиц, спросите у кого‑нибудь как пройти',
                buttonText: 'Попробовать снова',
                goBack: false,
              ),
            );
          } else {
            widget = const Scaffold(
              body: Center(
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
          return widget;
        }));
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
