import 'package:flutter/material.dart';
import 'package:myfinalpro/widget/page_route_names.dart';
import 'package:myfinalpro/widget/routes_generator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASPIQ',
      debugShowCheckedModeBanner: false,
      initialRoute: PageRouteName.initial,
      onGenerateRoute: RoutesGenerator.onGenerateRoute,
    );
  }
}
