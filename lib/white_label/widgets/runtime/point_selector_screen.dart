import 'package:flutter/material.dart';
import '../../../white_label/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Model for a pickup point
class PickupPoint {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? hours;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;

  const PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.hours,
    this.latitude,
    this.longitude,
    this.isAvailable = true,
  });

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      hours: json['hours'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      if (phone != null) 'phone': phone,
      if (hours != null) 'hours': hours,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isAvailable': isAvailable,
    };
  }
}

/// Provider for selected pickup point
final selectedPickupPointProvider = StateProvider<PickupPoint?>((ref) => null);

/// Point Selector Screen for Click & Collect module
/// 
/// Allows customers to select a pickup point/location for their order.
class PointSelectorScreen extends ConsumerStatefulWidget {
  /// Optional callback when a point is selected
  final void Function(PickupPoint point)? onPointSelected;

  const PointSelectorScreen({
    super.key,
    this.onPointSelected,
  });

  @override
  ConsumerState<PointSelectorScreen> createState() => _PointSelectorScreenState();
}

class _PointSelectorScreenState extends ConsumerState<PointSelectorScreen> {
  PickupPoint? _selectedPoint;

  // TODO: Load from restaurant config / Firestore
  // For now, using sample data
  final List<PickupPoint> _availablePoints = const [
    PickupPoint(
      id: 'point_1',
      name: 'Restaurant Principal',
      address: '123 Rue de la Pizza, 75001 Paris',
      phone: '01 23 45 67 89',
      hours: 'Lun-Dim: 11h-22h',
      latitude: 48.8566,
      longitude: 2.3522,
      isAvailable: true,
    ),
    PickupPoint(
      id: 'point_2',
      name: 'Point Relais Centre-Ville',
      address: '456 Avenue des Champs, 75008 Paris',
      phone: '01 98 76 54 32',
      hours: 'Lun-Sam: 9h-20h',
      latitude: 48.8738,
      longitude: 2.2950,
      isAvailable: true,
    ),
    PickupPoint(
      id: 'point_3',
      name: 'Point Relais Gare',
      address: '789 Place de la Gare, 75010 Paris',
      hours: 'Lun-Dim: 7h-23h',
      latitude: 48.8768,
      longitude: 2.3577,
      isAvailable: false,
    ),
  ];

  void _selectPoint(PickupPoint point) {
    if (!point.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le point "${point.name}" n\'est pas disponible actuellement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _selectedPoint = point;
    });

    // Update provider
    ref.read(selectedPickupPointProvider.notifier).state = point;

    // Call optional callback
    if (widget.onPointSelected != null) {
      widget.onPointSelected!(point);
    }
  }

  void _confirmSelection() {
    if (_selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un point de retrait'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Pop with selected point
    Navigator.of(context).pop(_selectedPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un point de retrait'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Sélectionnez un point de retrait pour votre commande',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // List of pickup points
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _availablePoints.length,
              itemBuilder: (context, index) {
                final point = _availablePoints[index];
                final isSelected = _selectedPoint?.id == point.id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _selectPoint(point),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      point.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      point.address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!point.isAvailable)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Indisponible',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                            ],
                          ),
                          if (point.phone != null || point.hours != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            if (point.phone != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    point.phone!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            if (point.hours != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                    point.hours!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedPoint != null ? _confirmSelection : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _selectedPoint != null
                        ? 'Confirmer le point de retrait'
                        : 'Sélectionnez un point',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
