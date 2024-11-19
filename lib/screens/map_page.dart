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

class _PropertyMapScreenState extends State<PropertyMapScreen>
    with WidgetsBindingObserver {
  late final CustomInfoWindowController _customInfoWindowController;
  late final PanelController _panelController;

  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(9.007923, 38.767821);
  Property? _selectedProperty;
  bool _isMapReady = false;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _customInfoWindowController = CustomInfoWindowController();
    _panelController = PanelController();
    WidgetsBinding.instance.addObserver(this);
    _initializeMap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _customInfoWindowController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _mapController != null) {
      setState(() {});
    }
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      if (_mapController != null && _isMapReady) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(
              widget.latitude ?? position.latitude,
              widget.longitude ?? position.longitude,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      debugPrint('Error getting location: $e');
    }
  }

  Set<Marker> _buildMarkers() {
    return widget.properties.map((property) {
      return Marker(
        markerId: MarkerId(property.id),
        position: LatLng(
          property.location.latitude,
          property.location.longitude,
        ),
        icon: _selectedProperty?.id == property.id
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onTap: () => _onMarkerTapped(property),
      );
    }).toSet();
  }

  void _onMarkerTapped(Property property) {
    setState(() => _selectedProperty = property);

    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(property.location.latitude, property.location.longitude),
      ),
    );

    _showPropertyDetails(property);
  }

  void _showPropertyDetails(Property property) {
    if (_panelController.isPanelClosed) {
      _panelController.open();
    }

    _customInfoWindowController.addInfoWindow!(
      _buildInfoWindowContent(property),
      LatLng(property.location.latitude, property.location.longitude),
    );
  }

  Widget _buildInfoWindowContent(Property property) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPropertyImage(property),
          const SizedBox(height: 8),
          _buildPropertyInfo(property),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(Property property) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        property.pictures[0].imageUrl,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 120,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildPropertyInfo(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
    setState(() => _isMapReady = true);

    if (_currentPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            widget.latitude ?? _currentPosition!.latitude,
            widget.longitude ?? _currentPosition!.longitude,
          ),
        ),
      );
    }
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties Map'),
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildBody() {
    return SlidingUpPanel(
      controller: _panelController,
      panel: _buildPanel(),
      collapsed: Container(),
      body: _buildMap(),
      minHeight: 0,
      maxHeight: MediaQuery.of(context).size.height * 0.7,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      onPanelClosed: () => setState(() => _selectedProperty = null),
    );
  }

  Widget _buildPanel() {
    if (_selectedProperty == null) return Container();

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
              property: _selectedProperty!,
              onWishlistToggle: (newValue) {
                setState(() {
                  _selectedProperty = _selectedProperty!.copyWith(
                    isWishListed: newValue,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.latitude ?? _currentPosition!.latitude,
              widget.longitude ?? _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
          markers: _buildMarkers(),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onTap: (_) => _customInfoWindowController.hideInfoWindow!(),
          onCameraMove: (_) => _customInfoWindowController.onCameraMove!(),
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
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 170, vertical: 5),
        child: Container(
          height: 5,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
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
          onPressed: () {
            // Implement map type toggle
          },
          child: const Icon(Icons.layers),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: 'location',
          onPressed: _getCurrentLocation,
          child: _isLoadingLocation
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.my_location),
        ),
      ],
    );
  }
}
