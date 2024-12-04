// lib/widgets/properties_list.dart
import 'package:flutter/material.dart';
import 'package:nibret/widgets/property_skeleton.dart';
import '../models/property.dart';
import 'property_card.dart';

class PropertiesList extends StatelessWidget {
  final List<Property> properties;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;

  const PropertiesList({
    Key? key,
    required this.properties,
    required this.isLoading,
    this.error,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => const PropertyCardSkeleton(),
      );
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: properties.length,
        itemBuilder: (context, index) =>
            PropertyCard(property: properties[index]),
      ),
    );
  }
}
