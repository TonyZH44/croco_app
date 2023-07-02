import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CityList extends StatefulWidget{
  const CityList({super.key});


  @override
  CityListState createState () => CityListState();
}

class CityListState extends State<CityList> {

  //late String futureList;
  late Future<List<City>> listOfCities;


  @override
  void initState() {
    super.initState();
    // fetchCityList().then((value) => {
    //   futureList = value
    // });

    listOfCities = fetchCityList();
    //listOfCities = parseCities(futureList);
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder<List>(
      future: listOfCities,
      builder: ((context, snapshot) {
        List<Widget> children = [];
        //children = <Widget>[];
        if (snapshot.hasData) {
          snapshot.data!.forEach((city) {
            children.add(city);
            //debugPrint(city.toString());
          });
        } else {
          children.add(
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            )
          );
        }
        return Center(
          child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
            )
          )
        );
      })
    );
    
  }
}

// Future<String> fetchCityList() async {
//   final response = await http.get(Uri.parse('https://649befbd0480757192372825.mockapi.io/api/v1/cities'));

//   if (response.statusCode == 200) {
//     String cityText = response.body;
    
//     return cityText;
//   } else {
//     throw Exception('Failed to load cities');
//   }
// }

Future<List<City>> fetchCityList() async {
  
  final response = await http.get(Uri.parse('https://649befbd0480757192372825.mockapi.io/api/v1/cities'));
  //debugPrint(response.body);
  if (response.statusCode == 200) {
    String cityText = response.body;
    
    return parseCities(cityText);
  } else {
    throw Exception('Failed to load cities');
  }
}

List<City> parseCities(String cityText) {
  
  var cityListJson = jsonDecode(cityText) as List;
  List<City> cityList = cityListJson.map((cityJson) => City.fromJson(cityJson)).toList();

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

  const City({ super.key,
    required this.id,
    required this.name,
    required this.image,
    required this.dateTimeImage,
    required this.totalPeople,
    required this.lat,
    required this.long
  });

  factory City.fromJson(Map<String, dynamic> json){
    return City(
      id: int.parse(json['id']),
      name: json['name'],
      image: json['image'],
      dateTimeImage: DateTime.parse(json['dateTimeImage']),
      totalPeople: json['totalPeople'],
      lat: double.parse(json['lat']),
      long: double.parse(json['long'])
    );
  }

  @override
  Widget build(BuildContext context){
    return Column(
      children: [
        Image.network(
          image,
          
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name),
            Text('$totalPeople человек'),
            Text('Широта $lat'),
            Text('Долгота $long'),
            Text('Фото сделано $dateTimeImage')
          ],
        )
      ],
    );
  }
}