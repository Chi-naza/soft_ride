import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soft_ride/Info_Handler/app_info.dart';
import 'package:soft_ride/constants/map_keys.dart';
import 'package:soft_ride/constants/request_methods.dart';
import 'package:soft_ride/models/directions_model.dart';
import 'package:soft_ride/models/predicted_places_model.dart';
import 'package:soft_ride/widgets/progress_dialog.dart';

class PlacePredictionTileDesign extends StatelessWidget {

  final PredictedPlacesModel? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});


  // Getting the details of the place picked by the user in the 'pick-destination-screen'
  Future<void> getPlaceDirectionDetails({required String placeID, required BuildContext context }) async {
    // show a dialog message
    showProgressDialog(message: "Setting Up Drof-Off, Please wait...", context: context);

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeID&key=$googleMapAPIkey";

    var responseApi = await RequestMethods.receiveRequest(placeDirectionDetailsUrl);

    await Future.delayed(const Duration(seconds: 3));

    // Removing the dialog message
    Navigator.pop(context);

    if(responseApi == "Error Occurred, Failed. No Response.") {
      return;
    }

    if(responseApi["status"] == "OK") {
      DirectionsModel directions = DirectionsModel();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeID;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];
      
      if(kDebugMode){
        print('LOCATION NAME: ${directions.locationName}');
        print('LOCATION ID: ${directions.locationId}');
        print('LOCATION LATITUDE: ${directions.locationLatitude}');
      }

      // ignore: use_build_context_synchronously
      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      Navigator.pop(context, "obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        getPlaceDirectionDetails(placeID: predictedPlaces!.place_id!, context: context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            // ADD LOCATION Icon
            const Icon(
              Icons.add_location,
              color: Colors.grey,
            ),
            const SizedBox(width: 14.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0,),
                  // Predicted Places MAIN TEXT
                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 2.0,),
                  // SECONDARY TEXT
                  Text(
                    predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
