import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'streetlist.dart';
import 'errorscreen.dart';

class CityListPage extends StatefulWidget {
  const CityListPage({super.key});

  @override
  CityListPageState createState() => CityListPageState();
}

class CityListPageState extends State<CityListPage> {
  late Future<List<City>> listOfCities;

  @override
  void initState() {
    //Инициализация страницы
    super.initState();

    listOfCities = fetchCityList(); //Загрузка городов
  }

  Future<List<City>> fetchCityList() async {
    final response = await http.get(Uri.parse(
        'https://649befbd0480757192372825.mockapi.io/api/v1/cities')); //Запрос для получения городов
    //Проверка ответа сервера
    if (response.statusCode == 200) {
      String cityJson = response.body;
      //String empty = '[]';      // Нужен для теста пустого списка
      return parseCities(cityJson);
    }
    throw Exception('Failed to load cities');
  }

  List<City> parseCities(String cityJson) {
    //Перевод строки Json в список Json объектов
    var cityJsonList = jsonDecode(cityJson) as List;
    //Перевод каждого Json объекта в виджет City
    List<City> cityList = cityJsonList
        .map((cityJsonObject) => City.fromJson(cityJsonObject))
        .toList();

    return cityList;
  }

  @override
  Widget build(BuildContext context) {
    //Строит дерево виджетов в зависимости от статуса ответа
    return FutureBuilder<List>(
        future: listOfCities,
        builder: ((context, snapshot) {
          Widget widget;
          List<Widget> children = [
            const SizedBox(
              //Для верхнего первого отступа
              height: 20,
            )
          ];
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            //Если все хорошо
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
            //Если пустой ответ или ошибка
            widget = Scaffold(
              body: ErrorScreen(
                  page: super.widget,
                  imageUrl: 'assets/fail-cities.png',
                  headerText: 'Оглядитесь…',
                  supportText:
                      'Нет ни городов, ни улиц. Очевидно, что‑то сломалось и мы уже это чиним.',
                  buttonText: 'Попробовать снова',
                  goBack: false),
            );
          } else {
            //Индикатор загрузки
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

class City extends StatelessWidget {
  //Виджет город
  final int id;
  final String name;
  final String image; //Ссылка на фото
  final DateTime dateTimeImage;
  final int totalPeople;
  final double lat; //Широта
  final double long; //Долгота

  const City(
      {super.key,
      required this.id,
      required this.name,
      required this.image,
      required this.dateTimeImage,
      required this.totalPeople,
      required this.lat,
      required this.long});

  //Фабричный конструктор из Json объекта
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
    String formatedTime =
        DateFormat.yMMMMd('ru').format(dateTimeImage); //Форматированная дата
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 228, 228, 228)),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        //width: 328,
        //height: 426,
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
                //SizedBoxes используются для отступов, вместо margin
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
                  Text('Широта $lat°',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text('Долгота $long°',
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  const SizedBox(
                    height: 16,
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
