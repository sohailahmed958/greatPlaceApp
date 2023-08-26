import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greatplaceapp/helpers/db_helper.dart';
import 'package:greatplaceapp/helpers/location_helper.dart';
import 'package:greatplaceapp/models/place.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];
  List<Place> get items {
    return [..._items];
  }

  Place findById(String id) {
    return _items.firstWhere((place) => place.id == id);
  }

  GreatPlaces() {
    // Fetch data from the database only once when the provider is initialized
    fetchAndSetPlaces();
  }

  Future<void> addPlace(String pickedTitle, File pickedImage,
      PlaceLocation pickedLocation) async {
    final address = await LocationHelper.getPlaceAddress(
        pickedLocation.latitude!, pickedLocation.longitude!);
    final updatedLocation = PlaceLocation(
        latitude: pickedLocation.latitude,
        longitude: pickedLocation.longitude,
        address: address);
    final newPlace = Place(
      id: DateTime.now().toString(),
      title: pickedTitle,
      image: pickedImage,
      location: updatedLocation,
    );
    _items.add(newPlace);
    notifyListeners();
    //final db = await DBHelper.database();
    //await db
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'loc_lat': newPlace.location.latitude!,
      'loc_lng': newPlace.location.longitude!,
      'address': newPlace.location.address!,
    });
  }

  Future<void> fetchAndSetPlaces() async {
    // final db = await DBHelper.database();
    // final dataList = await db.query('user_places');
    final dataList = await DBHelper.getData('user_places');

    _items = dataList
        .map((item) => Place(
            id: item['id'],
            title: item['title'],
            location: PlaceLocation(
              latitude: item['loc_lat'],
              longitude: item['loc_lng'],
              address: item['address'],
            ),
            image: File(item['image'])))
        .toList();
    print('These are fetched Data: $_items');
    notifyListeners();
  }
}
