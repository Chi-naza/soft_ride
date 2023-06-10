import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:soft_ride/Firebase_Service/global.dart';
import 'package:soft_ride/Info_Handler/app_info.dart';
import 'package:soft_ride/constants/helper_methods.dart';
import 'package:soft_ride/mainScreens/search_places_screen.dart';
import 'package:soft_ride/widgets/custom_drawer.dart';
import 'package:soft_ride/widgets/progress_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // Setting up Google Map
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;


  // The Camera Position
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  // Scaffold key
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();

  // For animated container
  double searchLocationContainerHeight = 220;

  // For Geo Location
  Position? userCurrentPosition;
  
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;


  // For PolyLines
  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polyLineSet = {};

  // For Markers
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};


  // A function which tracks user's location per time
  Future<void> locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    if(kDebugMode)print('CURRENT POSITION GOTTEN: LAT - ${userCurrentPosition!.latitude}, LONG - ${userCurrentPosition!.longitude}');

    // ignore: use_build_context_synchronously
    String humanReadableAddress = await HelperMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    if(kDebugMode)print("USER'S ACTUAL ADDRESS = $humanReadableAddress");
  }


  // Check if User has given Location permission
  Future<void> checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }




  // A function which will draw the poly-lines from source - destination.
  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    // Progress dialog widget
    showProgressDialog(message: "Please wait...", context: context);

    var directionDetailsInfo = await HelperMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    // Popping off progress indicator
    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    // Decoding the polyLine by passing the fetched points from the user's description to Flutter-Polyline_Points
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.ePoints!);

    // Emptying the coordinates list before we set a new series of point coordinates to it. Coming from the decoded pLine points
    pLineCoOrdinatesList.clear();

    // Looping through each of the polyline points in the decodedPolylinePoints and adding them to pLineCoOrdinateList
    if(decodedPolyLinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsResultList) {
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    // clear the polyline SET before adding a new value to it
    polyLineSet.clear(); 

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap, 
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    // Creating an instance of latlng bounds which will be used to animate the camera when initialized.
    LatLngBounds boundsLatLng;

    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }
    
    // Here we animate the googleMap camera according to the latlng bounds
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    // Marker originMarker = Marker(
    //   markerId: const MarkerId("originID"),
    //   infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
    //   position: originLatLng,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    // );

    // Marker destinationMarker = Marker(
    //   markerId: const MarkerId("destinationID"),
    //   infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
    //   position: destinationLatLng,
    //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    // );

    // setState(() {
    //   markersSet.add(originMarker);
    //   markersSet.add(destinationMarker);
    // });

    // Circle originCircle = Circle(
    //   circleId: const CircleId("originID"),
    //   fillColor: Colors.green,
    //   radius: 12,
    //   strokeWidth: 3,
    //   strokeColor: Colors.white,
    //   center: originLatLng,
    // );

    // Circle destinationCircle = Circle(
    //   circleId: const CircleId("destinationID"),
    //   fillColor: Colors.red,
    //   radius: 12,
    //   strokeWidth: 3,
    //   strokeColor: Colors.white,
    //   center: destinationLatLng,
    // );

    // setState(() {
    //   circlesSet.add(originCircle);
    //   circlesSet.add(destinationCircle);
    // });
  }



  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,
      drawer: Container(
        width: 265,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: MyDrawerWidget(
            name: userModelCurrentInfo!.name,
            email: userModelCurrentInfo!.email,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polyLineSet,
            markers: markersSet,
            circles: circlesSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              //for black theme google map
              blackThemeGoogleMap();
              // Move the Google Map Area Upwards using bottom padding
              setState(() {
                bottomPaddingOfMap = 240;
              });
              // locating user's exact position in real time
              locateUserPosition();
            },
          ),
          //custom hamburger button for drawer
          Positioned(
            top: 30,
            left: 14,
            child: GestureDetector(
              onTap: () {
                sKey.currentState!.openDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.menu,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          // FROM (location) ----- To (location) of users
          // Searching Location By Users
           Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    children: [
                      //from
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context).userPickUpLocation != null? 
                                  "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,35)}..."
                                  : 
                                  "Unable to fecth your address",
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      const Divider(height: 1, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 16.0),
                      // TO
                      GestureDetector(
                        onTap: () async {
                          // Go to search for places screen
                          var responseFromSearchScreen = await Navigator.of(context).push(MaterialPageRoute(builder: (c) => const SearchPlacesScreen()));

                          if(responseFromSearchScreen == "obtainedDropoff"){
                            // Draw Polyline
                            print('I am drawing lines now');
                            await drawPolyLineFromOriginToDestination();
                          }

                        }, 
                        child: Row(
                          children: [
                            const Icon(Icons.add_location_alt_outlined, color: Colors.grey),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context).userDropOffLocation != null?
                                  Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                  :
                                  "Where do you intend to go?",
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Divider(height: 1, thickness: 1, color: Colors.grey),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        child: Text("Request a Ride"),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }




// A function which implements Black Theme for the Google Map View

  void blackThemeGoogleMap() {
    newGoogleMapController!.setMapStyle('''
      [
        {
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#242f3e"
            }
          ]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#746855"
            }
          ]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#242f3e"
            }
          ]
        },
        {
          "featureType": "administrative.locality",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "poi",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#263c3f"
            }
          ]
        },
        {
          "featureType": "poi.park",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#6b9a76"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#38414e"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "geometry.stroke",
          "stylers": [
            {
              "color": "#212a37"
            }
          ]
        },
        {
          "featureType": "road",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#9ca5b3"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#746855"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "geometry.stroke",
          "stylers": [
            {
              "color": "#1f2835"
            }
          ]
        },
        {
          "featureType": "road.highway",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#f3d19c"
            }
          ]
        },
        {
          "featureType": "transit",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#2f3948"
            }
          ]
        },
        {
          "featureType": "transit.station",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#d59563"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "geometry",
          "stylers": [
            {
              "color": "#17263c"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.fill",
          "stylers": [
            {
              "color": "#515c6d"
            }
          ]
        },
        {
          "featureType": "water",
          "elementType": "labels.text.stroke",
          "stylers": [
            {
              "color": "#17263c"
            }
          ]
        }
      ]
  ''');
  }


}