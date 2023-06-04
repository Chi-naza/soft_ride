import 'package:flutter/material.dart';
import 'package:soft_ride/models/directions_model.dart';

class AppInfo extends ChangeNotifier {
  DirectionsModel? userPickUpLocation;


  void updatePickUpLocationAddress(DirectionsModel userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
  
}