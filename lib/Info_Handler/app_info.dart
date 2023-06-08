import 'package:flutter/material.dart';
import 'package:soft_ride/models/directions_model.dart';

class AppInfo extends ChangeNotifier {
  DirectionsModel? userPickUpLocation, userDropOffLocation;


  void updatePickUpLocationAddress(DirectionsModel userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(DirectionsModel dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
  
}