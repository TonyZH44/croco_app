import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'citylist.dart';

void main() {
  initializeDateFormatting(); //Для локализации и форматирования даты
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: Colors.white,
              primary: Colors.white,
              onPrimary: Colors.black),
          fontFamily: 'Inter',
        ),
        home: const CityListPage());
  }
}
