import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/Info_Handler/app_info.dart';
import 'package:soft_ride/constants/map_keys.dart';
import 'package:soft_ride/constants/request_methods.dart';
import 'package:soft_ride/models/directions_details_info_model.dart';
import 'package:soft_ride/models/directions_model.dart';
import 'package:soft_ride/models/user_model.dart';

class HelperMethods {

  // A method for fetching current user info from DB
  static Future<void> readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    // Getting the current user's data using the user's ID
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users").child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if(snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        print('USER: \nName: ${userModelCurrentInfo!.name} \nEmail: ${userModelCurrentInfo!.email}');
      }
    });
  }





  // A method for retrieving the physical location of the user using reverse geocoding
  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async {
    
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapAPIkey";

    String humanReadableAddress="";

    var requestResponse = await RequestMethods.receiveRequest(apiUrl);

    if(requestResponse != "Error Occurred, Failed. No Response.") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      DirectionsModel userPickUpAddress = DirectionsModel();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }




  static Future<DirectionDetailsInfoModel?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {
    if(kDebugMode){
      print("S-LAT: ${originPosition.latitude}");
      print("S-LONG: ${originPosition.longitude}");
      print("D-LAT: ${destinationPosition.latitude}");
      print("D-LONG: ${destinationPosition.longitude}");
    }

    // Directions API endpoint
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$googleMapAPIkey";
    // String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=34.1330949,-117.9143879&destination=33.8068768,-118.3527671&key=$googleMapAPIkey";

    var responseDirectionApi = await RequestMethods.receiveRequest(urlOriginToDestinationDirectionDetails); 

    if(responseDirectionApi == "Error Occurred, Failed. No Response.") return null;
    
    // Initializing our model
    DirectionDetailsInfoModel directionDetailsInfo = DirectionDetailsInfoModel();
    directionDetailsInfo.ePoints = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distanceText = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanceValue = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.durationText = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.durationValue = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }





}