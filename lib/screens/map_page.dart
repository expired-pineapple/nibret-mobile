import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../models/property.dart';
import '../widgets/property_card.dart';

class PropertyMapScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final List<Property> properties;

  const PropertyMapScreen({
    super.key,
    this.latitude,
    this.longitude,
    required this.properties,
  });

  @override
  _PropertyMapScreenState createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Property? _selectedProperty;
  final Set<Marker> _markers = {};
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addPropertyMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              widget.latitude ?? position.latitude,
              widget.longitude ?? position.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _addPropertyMarkers() {
    setState(() {
      _markers.addAll(
        widget.properties.map(
          (property) => Marker(
            markerId: MarkerId(property.id),
            position: LatLng(
              property.location.latitude,
              property.location.longitude,
            ),
            onTap: () {
              setState(() {
                _selectedProperty = property;
              });
              _panelController.open();

              _mapController?.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(
                    property.location.latitude,
                    property.location.longitude,
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties Map'),
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        panel: _selectedProperty != null
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    // Handle bar indicator
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    PropertyCard(
                      property: _selectedProperty!,
                      onWishlistToggle: (bool newValue) {
                        setState(() {
                          _selectedProperty = _selectedProperty!.copyWith(
                            isWishListed: newValue,
                          );
                        });
                        // Add your wishlist update logic here
                      },
                    ),
                  ],
                ),
              )
            : Container(),
        collapsed: Container(),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.latitude ?? _currentPosition?.latitude ?? 0.0,
                  widget.longitude ?? _currentPosition?.longitude ?? 0.0,
                ),
                zoom: 15,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (_currentPosition != null) {
                  _getCurrentLocation();
                }
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onTap: (_) {
                _panelController.close();
              },
            ),
            // Search bar overlay
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search location...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    // Add search functionality here
                  },
                ),
              ),
            ),
          ],
        ),
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        onPanelClosed: () {
          setState(() {
            _selectedProperty = null;
          });
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'layers',
            onPressed: () {
              // Add map type/layer toggle functionality
            },
            child: const Icon(Icons.layers),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
