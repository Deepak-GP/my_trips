

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:trips/models/data_holder.dart';
import 'package:trips/models/destinationModel.dart';
import 'package:trips/screens/add_trips.dart';

class DestinationList extends StatelessWidget {
 
  final List<DocumentSnapshot> snapshot;

  DestinationList({@required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Top Trips', 
              style: TextStyle(
                color: Colors.black,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushNamed(context, AddTrip.route);
                },
                child: Text('Add trip',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 400,
          child: ListView.builder(
              itemCount: snapshot.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index)
              {
                var destinationRecord = Destination.fromSnapshot(snapshot[index]);
                return DestinationContainer(destinationRecord: destinationRecord,);
              },
          ),
        ),
      ],
    );
  }
}

class DestinationContainer extends StatefulWidget {
  
  final Destination destinationRecord;

  DestinationContainer({@required this.destinationRecord});

  @override
  _DestinationContainerState createState() => _DestinationContainerState();
}

class _DestinationContainerState extends State<DestinationContainer> {
  
  Uint8List imageFile;

  Future _getWallpaper(StorageReference photoRef, Destination destinationRecord) async
  {
    if(destinationRecord.wallpaperUrl != null && destinationRecord.wallpaperUrl.isEmpty == false)
    {
      int maxSize = 17*1024*1024;
      var imageUint8List = await photoRef.child(destinationRecord.wallpaperUrl).getData(maxSize);
      requestedWallpaper.add(destinationRecord.wallpaperUrl);
      imageData.putIfAbsent(destinationRecord.wallpaperUrl, () {
        return Image.memory(imageUint8List, fit: BoxFit.cover, height: 260, width: 280,);
      });
      return imageUint8List;
    }
  }


  @override
  Widget build(BuildContext context) {
    StorageReference photosReference = FirebaseStorage.instance.ref().child(widget.destinationRecord.city);
    StorageReference wallpaperReference = photosReference.child('wallpaper');
    return GestureDetector(
      onTap: () {
        
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        width: 310,
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Positioned(
              bottom: 15.0,
              child: Container(
                width: 300,
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Visited on ${widget.destinationRecord.visitedDate.toDate().year}-${widget.destinationRecord.visitedDate.toDate().month}-${widget.destinationRecord.visitedDate.toDate().day}', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                      Text('${widget.destinationRecord.description}', style: TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6.0,
                    offset: Offset(0.0,2.0),
                    color: Colors.black26
                  )
                ]
              ),
              child: Stack(
                children: <Widget>[
                  imageData.containsKey(widget.destinationRecord.wallpaperUrl) ? Hero(
                    tag: imageData[widget.destinationRecord.wallpaperUrl],
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: imageData[widget.destinationRecord.wallpaperUrl],
                    ),
                  ) :
                  FutureBuilder(
                    future: _getWallpaper(wallpaperReference, widget.destinationRecord),
                    builder: (BuildContext context, AsyncSnapshot snapShot)
                    {
                      if(snapShot.hasData)
                      {
                        return Hero(
                          tag: snapShot.data,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: imageData[widget.destinationRecord.wallpaperUrl],
                          ),
                        );
                      }
                      else
                      {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  Positioned(
                      bottom: 10.0,
                      left: 10.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.destinationRecord.city,
                            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.locationArrow, color: Colors.white,size: 10.0,),
                              SizedBox(width: 5.0),
                              Text(
                                widget.destinationRecord.country,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}