import 'package:flutter/material.dart';

class PropertyFilters extends StatelessWidget {
  final RangeValues priceRange;
  final Function(RangeValues) onPriceRangeChanged;
  final int? selectedBedrooms;
  final Function(int?) onBedroomsChanged;
  final int? selectedBathrooms;
  final Function(int?) onBathroomsChanged;
  final String? selectedPropertyType;
  final Function(String?) onPropertyTypeChanged;

  const PropertyFilters({
    super.key,
    required this.priceRange,
    required this.onPriceRangeChanged,
    this.selectedBedrooms,
    required this.onBedroomsChanged,
    this.selectedBathrooms,
    required this.onBathroomsChanged,
    this.selectedPropertyType,
    required this.onPropertyTypeChanged,
  });

  Widget _buildNumberButton(
      String label, bool isSelected, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF0668FE) : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: 0,
        side: BorderSide(
          color: isSelected ? const Color(0xFF0668FE) : Colors.grey,
          width: 1,
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPropertyTypeCard(
      String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0668FE) : Colors.grey,
          width: 2.0,
        ),
      ),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF0668FE) : Colors.black,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF0668FE) : Colors.black,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Filters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Price Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: priceRange,
                    min: 5,
                    max: 1000,
                    divisions: 100,
                    activeColor: const Color(0xFF0668FE),
                    labels: RangeLabels(
                      '\$${priceRange.start.round()}k',
                      '\$${priceRange.end.round()}k',
                    ),
                    onChanged: onPriceRangeChanged,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bedrooms',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Any', '1', '2', '3', '4'].map((value) {
                        final numValue =
                            value == 'Any' ? null : int.parse(value);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildNumberButton(
                            value,
                            selectedBedrooms == numValue,
                            () => onBedroomsChanged(numValue),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Bathrooms',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Any', '1', '2', '3', '4'].map((value) {
                        final numValue =
                            value == 'Any' ? null : int.parse(value);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildNumberButton(
                            value,
                            selectedBathrooms == numValue,
                            () => onBathroomsChanged(numValue),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Property Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyTypeCard(
                          'Luxury Apartment',
                          Icons.apartment_outlined,
                          selectedPropertyType == 'apartment',
                          () => onPropertyTypeChanged('apartment'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPropertyTypeCard(
                          'Villa',
                          Icons.villa_outlined,
                          selectedPropertyType == 'villa',
                          () => onPropertyTypeChanged('villa'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPropertyTypeCard(
                          'Plot Land',
                          Icons.landscape_outlined,
                          selectedPropertyType == 'plot',
                          () => onPropertyTypeChanged('plot'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPropertyTypeCard(
                          'House',
                          Icons.home_outlined,
                          selectedPropertyType == 'house',
                          () => onPropertyTypeChanged('house'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0668FE),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
