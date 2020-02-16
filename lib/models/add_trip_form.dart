
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTripFormData
{
  String destinationImgUrl;
  String city;
  String country;
  String description;
  Timestamp visitedDate;
  String durationOfTrip;
  String storagePath;
  String wallpaperUrl;

  Map<String, dynamic> toJSON() =>
  {
    'destinationImgUrl': destinationImgUrl,
    'city': city,
    'country': country,
    'description': description,
    'visitedDate': visitedDate,
    'durationOfTrip': durationOfTrip,
    'wallpaperUrl': wallpaperUrl
  };

}