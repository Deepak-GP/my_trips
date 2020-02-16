import 'package:flutter/material.dart';
import 'package:trips/screens/add_trips.dart';
import 'package:trips/screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF3EBACE),
        accentColor: Color(0xFFD8ECF1),
        scaffoldBackgroundColor: Color(0xFFF3F3F5F7),
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        AddTrip.route : (context) => AddTrip(),
      },
    );
  }
}

