import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/constants/map_keys.dart';
import 'package:soft_ride/constants/request_methods.dart';
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

      // Directions userPickUpAddress = Directions();
      // userPickUpAddress.locationLatitude = position.latitude;
      // userPickUpAddress.locationLongitude = position.longitude;
      // userPickUpAddress.locationName = humanReadableAddress;

      // Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

}