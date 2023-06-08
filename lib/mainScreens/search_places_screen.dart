import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soft_ride/constants/map_keys.dart';
import 'package:soft_ride/constants/request_methods.dart';
import 'package:soft_ride/models/predicted_places_model.dart';
import 'package:soft_ride/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}




class _SearchPlacesScreenState extends State<SearchPlacesScreen> { 

  // List holding the predicted places gotten from Places Auto Search
  List<PredictedPlacesModel> placesPredictedList = [];


  // A method that will implement the Place Auto Complete Search
  Future<void> findPlaceAutoCompleteSearch(String inputText) async {
    // 2 or more than 2 input characters will trigger the autoComplete
    if(inputText.length > 1) {
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$googleMapAPIkey&components=country:NG";
      
      // A variable that will hold the fetched suggested places
      var responseAutoCompleteSearch = await RequestMethods.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error Occurred, Failed. No Response.") {
        return;
      }

      if(responseAutoCompleteSearch["status"] == "OK") {
        // getting the predictions
        var placePredictions = responseAutoCompleteSearch["predictions"];
        // Testing
        if(kDebugMode) print(responseAutoCompleteSearch);
        // Converting the data to List and deserializing it
        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlacesModel.fromJson(jsonData)).toList();

        setState(() {
          // populating our list
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }




    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          //search place UI
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: Colors.black54,
              boxShadow:
              [
                BoxShadow(
                  color: Colors.white54,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const SizedBox(height: 25.0),
                  Stack(
                    children: [
                      // Arrow Back Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        ),
                      ),
                      // Search & Set DropOFF TEXT
                      const Center(
                        child: Text(
                          "Search & Set DropOff Location",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Icon & Textfield for Searching places
                  Row(
                    children: [
                      // Icon: adjust_sharp
                      const Icon(
                        Icons.adjust_sharp,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 18.0,),
                      // The textfield
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (valueTyped) {
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration: const InputDecoration(
                              hintText: "Search here...",
                              fillColor: Colors.white54,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Display place predictions result
          (placesPredictedList.isNotEmpty)
            ? Expanded(
                child: ListView.separated(
                  itemCount: placesPredictedList.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return PlacePredictionTileDesign(
                      predictedPlaces: placesPredictedList[index],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      height: 1,
                      color: Colors.white,
                      thickness: 1,
                    );
                  },
                ),
              )
            : Container(),
        ],
      ),
    );
  }
}