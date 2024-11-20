import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:custom_info_window/custom_info_window.dart';
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
  State<PropertyMapScreen> createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  final CustomInfoWindowController _customInfoWindowController =
      CustomInfoWindowController();
  final PanelController _panelController = PanelController();
  final ValueNotifier<bool> _isLoadingLocation = ValueNotifier<bool>(false);
  final ValueNotifier<Property?> _selectedProperty =
      ValueNotifier<Property?>(null);

  GoogleMapController? _mapController;
  late final ValueNotifier<LatLng> _currentPosition;
  late final ValueNotifier<bool> _isMapReady;
  MapType _currentMapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _currentPosition = ValueNotifier<LatLng>(const LatLng(9.007923, 38.767821));
    _isMapReady = ValueNotifier<bool>(false);
    _initializeMap();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _customInfoWindowController.dispose();
    _currentPosition.dispose();
    _isMapReady.dispose();
    _isLoadingLocation.dispose();
    _selectedProperty.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation.value) return;
    _isLoadingLocation.value = true;

    try {
      final permission = await _checkLocationPermission();
      if (!permission) {
        _isLoadingLocation.value = false;
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition.value = LatLng(position.latitude, position.longitude);

      if (_mapController != null && _isMapReady.value) {
        await _animateToPosition(
          latitude: widget.latitude ?? position.latitude,
          longitude: widget.longitude ?? position.longitude,
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      _isLoadingLocation.value = false;
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      return permission != LocationPermission.denied;
    }
    return permission != LocationPermission.deniedForever;
  }

  Future<void> _animateToPosition({
    required double latitude,
    required double longitude,
  }) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(latitude, longitude)),
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      for (final property in widget.properties)
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(
            property.location.latitude,
            property.location.longitude,
          ),
          icon: _selectedProperty.value?.id == property.id
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          onTap: () => _onMarkerTapped(property),
        )
    };
  }

  void _onMarkerTapped(Property property) {
    _selectedProperty.value = property;
    _showPropertyDetails(property);
  }

  void _showPropertyDetails(Property property) {
    if (_panelController.isPanelClosed) {
      _panelController.open();
    }

    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;

      _animateToPosition(
        latitude: property.location.latitude,
        longitude: property.location.longitude,
      ).then((_) {
        if (mounted) {
          _customInfoWindowController.addInfoWindow!(
            _buildInfoWindowContent(property),
            LatLng(property.location.latitude, property.location.longitude),
          );
        }
      });
    });
  }

  Widget _buildInfoWindowContent(Property property) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildPropertyImage(property)),
              const SizedBox(height: 8),
              _buildPropertyInfo(property),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyImage(Property property) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        property.pictures[0].imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildPropertyInfo(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '\$${property.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          property.description,
          style: const TextStyle(fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _customInfoWindowController.googleMapController = controller;
    _isMapReady.value = true;

    if (_currentPosition.value != null) {
      _animateToPosition(
        latitude: widget.latitude ?? _currentPosition.value.latitude,
        longitude: widget.longitude ?? _currentPosition.value.longitude,
      );
    }
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties Map'),
        elevation: 0,
      ),
      body: SlidingUpPanel(
        controller: _panelController,
        panel: _buildPanel(),
        collapsed: Container(),
        body: _buildMap(),
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        onPanelClosed: () => _selectedProperty.value = null,
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildPanel() {
    return ValueListenableBuilder<Property?>(
      valueListenable: _selectedProperty,
      builder: (context, property, _) {
        if (property == null) return const SizedBox.shrink();

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                  property: property,
                  onWishlistToggle: (newValue) {
                    _selectedProperty.value = property.copyWith(
                      isWishListed: newValue,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        ValueListenableBuilder<LatLng>(
          valueListenable: _currentPosition,
          builder: (context, position, _) {
            return GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.latitude ?? position.latitude,
                  widget.longitude ?? position.longitude,
                ),
                zoom: 15,
              ),
              mapType: _currentMapType,
              markers: _buildMarkers(),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onTap: (_) => _customInfoWindowController.hideInfoWindow!(),
              onCameraMove: (_) => _customInfoWindowController.onCameraMove!(),
            );
          },
        ),
        CustomInfoWindow(
          controller: _customInfoWindowController,
          height: 200,
          width: 300,
          offset: 35,
        ),
        _buildDragHandle(),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Positioned(
      top: 5,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Container(
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'layers',
          onPressed: _toggleMapType,
          child: const Icon(Icons.layers),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: _isLoadingLocation,
          builder: (context, isLoading, _) {
            return FloatingActionButton(
              heroTag: 'location',
              onPressed: _getCurrentLocation,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.my_location),
            );
          },
        ),
      ],
    );
  }
}
