import 'package:flutter/material.dart';
import 'package:trips/screens/add_trips.dart';
import 'package:trips/screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        AddTrip.route : (context) => AddTrip(),
      },
    );
  }
}

