

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trips/models/photos_model.dart';

class Destination
{
  String city;
  String country;
  String description;
  Timestamp visitedDate;
  String durationOfTrip;
  String storagePath;
  String wallpaperUrl;
  List<dynamic> images;
  Uint8List wallPaperImage;
  List<Photo> photos;
  Map<dynamic, Photo> mappedPhotos;
  Map<String,Image> wallpaperMap;

  final DocumentReference reference;

  Destination.fromMap(Map<String, dynamic> map, {this.reference}) :
    city = map.containsKey('city') ? map['city'] : '',
    country = map.containsKey('country') ? map['country'] : '',
    storagePath = map.containsKey('storagePath') ? map['storagePath'] : '',
    wallpaperUrl = map.containsKey('wallpaperUrl') ? map['wallpaperUrl'] : '',
    images = map.containsKey('images') ? map['images'] : new List<dynamic>(),
    visitedDate = map.containsKey('visitedDate') ? map['visitedDate'] : new Timestamp(0, 0),
    description = map.containsKey('description') ? map['description'] : '',
    photos = new List<Photo>(),
    wallpaperMap = {},
    mappedPhotos = {};


  Destination.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

}