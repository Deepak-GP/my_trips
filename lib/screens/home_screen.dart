
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trips/widgets/destination_container.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final Firestore destinationsDatabaseRef = Firestore.instance;
  Uint8List imageFile;

  _destinationCarousel()
  {
    return StreamBuilder<QuerySnapshot>(
      stream: destinationsDatabaseRef.collection('Destinations').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot)
      {
        if(!snapshot.hasData) return LinearProgressIndicator();

        else
        {
          //return _destinationList(context, snapshot.data.documents);
          return DestinationList(snapshot: snapshot.data.documents,);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 35.0),
          children: <Widget>[
            Text(
              'Trips travelled',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 40.0
              ),
            ),
            SizedBox(height: 30.0),
            _destinationCarousel(),
          ],
        ),
      ),
    );
  }
}

