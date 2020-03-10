
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trips/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:trips/blocs/authentication_bloc/authentication_event.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Trips travelled',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    BlocProvider.of<AuthenticationBloc>(context).add(
                      LoggedOut(),
                    );
                  },
                )
              ],
            ),
            SizedBox(height: 30.0),
            _destinationCarousel(),
          ],
        ),
      ),
    );
  }
}

