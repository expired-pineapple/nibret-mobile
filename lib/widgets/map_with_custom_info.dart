import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nibret/models/property.dart';
import 'package:nibret/screens/detail.dart';
import 'package:nibret/services/property_api.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  // ignore: unused_field
  String? _error;
  LatLng? _currentLocation;
  late GoogleMapController googleMapController;
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();

  List<Property> listOfPlace = [];
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadProperties();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      googleMapController.animateCamera(
        CameraUpdate.newLatLng(_currentLocation!),
      );
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _currentLocation = const LatLng(9.00792, 38.767821); // Default location
      });
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getProperties();

      final List<dynamic> jsonList = data['results'];
      final newItems = jsonList.map((json) => Property.fromJson(json)).toList();
      print(newItems);
      if (!mounted) return;

      setState(() {
        listOfPlace = newItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Oops,Something went wrong.";
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadProperties,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(9.00792, 38.767821),
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
              _customInfoWindowController.googleMapController = controller;
            },
            onTap: (argument) {
              _customInfoWindowController.hideInfoWindow!();
            },
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            markers: newMarkers(),
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            height: size.height * 0.28,
            width: size.width * 0.85,
            offset: 50,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Set<Marker> newMarkers() {
    Size size = MediaQuery.of(context).size;
    return Set<Marker>.of(
      listOfPlace.map(
        (place) {
          return Marker(
            markerId: MarkerId(place.name),
            position: LatLng(place.location.latitude, place.location.longitude),
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                Container(
                  height: size.height * 0.2,
                  width: size.width * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            height: size.height * 0.203,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25),
                                topRight: Radius.circular(25),
                              ),
                              child: AnotherCarousel(
                                images: place.pictures
                                    .map((picture) =>
                                        NetworkImage(picture.imageUrl))
                                    .toList(),
                                dotSize: 5,
                                indicatorBgPadding: 5,
                                dotBgColor: Colors.transparent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PropertyDetails(
                                          place.id,
                                          propertyId: place.id,
                                        )),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.location.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: '\$${place.price}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                LatLng(
                  place.location.latitude,
                  place.location.longitude,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
