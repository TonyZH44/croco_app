import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'streetlist.dart';
import 'errorscreen.dart';

class CityList extends StatefulWidget {
  const CityList({super.key});

  @override
  CityListState createState() => CityListState();
}

class CityListState extends State<CityList> {
  //late String futureList;
  late Future<List<City>> listOfCities;

  @override
  void initState() {
    super.initState();

    listOfCities = fetchCityList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: listOfCities,
        builder: ((context, snapshot) {
          Widget widget;
          List<Widget> children = [];
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            for (var city in snapshot.data!) {
              children.add(city);
            }
            widget = Scaffold(
                appBar: AppBar(
                  systemOverlayStyle: const SystemUiOverlayStyle(
                      statusBarColor: Colors.white,
                      statusBarIconBrightness: Brightness.dark),
                  shadowColor: Colors.white,
                  elevation: 0,
                  title: const Text(
                    'Города',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                  ),
                ),
                body: Center(
                    child: SingleChildScrollView(
                        child: Column(children: children))));
          } else if (snapshot.hasError ||
              (snapshot.hasData && snapshot.data!.isEmpty)) {
            widget = Scaffold(
              body: ErrorScreen(
                  parent: super.widget,
                  imageUrl: 'assets/fail-cities.png',
                  headerText: 'Оглядитесь…',
                  supportText:
                      'Нет ни городов, ни улиц. Очевидно, что‑то сломалось и мы уже это чиним.',
                  buttonText: 'Попробовать снова',
                  goBack: false),
            );
          } else {
            widget = const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    backgroundColor: Color.fromRGBO(242, 243, 245, 1),
                    color: Colors.black,
                    strokeWidth: 6,
                  ),
                ),
              ),
            );
          }
          return widget;
        }));
  }
}

Future<List<City>> fetchCityList() async {
  final response = await http.get(
      Uri.parse('https://649befbd0480757192372825.mockapi.io/api/v1/cities'));
  if (response.statusCode == 200) {
    String cityText = response.body;
    //String empty = '[]';
    return parseCities(cityText);
  } else {
    throw Exception('Failed to load cities');
  }
}

List<City> parseCities(String cityText) {
  var cityListJson = jsonDecode(cityText) as List;
  List<City> cityList =
      cityListJson.map((cityJson) => City.fromJson(cityJson)).toList();

  return cityList;
}

class City extends StatelessWidget {
  final int id;
  final String name;
  final String image;
  final DateTime dateTimeImage;
  final int totalPeople;
  final double lat;
  final double long;

  const City(
      {super.key,
      required this.id,
      required this.name,
      required this.image,
      required this.dateTimeImage,
      required this.totalPeople,
      required this.lat,
      required this.long});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
        id: int.parse(json['id']),
        name: json['name'],
        image: json['image'],
        dateTimeImage: DateTime.parse(json['dateTimeImage']),
        totalPeople: json['totalPeople'],
        lat: double.parse(json['lat']),
        long: double.parse(json['long']));
  }

  @override
  Widget build(BuildContext context) {
    String formatedTime = DateFormat.yMMMMd('ru').format(dateTimeImage);
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 228, 228, 228)),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        width: 328,
        height: 426,
        child: GestureDetector(
          onTap: (() {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StreetListPage(cityId: id),
                ));
          }),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  image: DecorationImage(
                      image: NetworkImage(image), fit: BoxFit.cover),
                ),
                width: 296,
                height: 240,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text('$totalPeople человек',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  const SizedBox(
                    height: 8,
                  ),
                  Text('Широта $lat',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text('Долгота $long',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  const SizedBox(
                    height: 8,
                  ),
                  Text('Фото сделано $formatedTime',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(102, 112, 133, 100)))
                ],
              )
            ],
          ),
        ));
  }
}
