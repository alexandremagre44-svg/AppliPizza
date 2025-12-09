import 'package:flutter/material.dart';

/// Model for a pickup point
class PickupPoint {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final List<String> openingHours;
  final bool isAvailable;
  final double? latitude;
  final double? longitude;

  const PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.openingHours = const [],
    this.isAvailable = true,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'openingHours': openingHours,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    return PickupPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      openingHours: (json['openingHours'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isAvailable: json['isAvailable'] as bool? ?? true,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

/// Point Selector Screen for Click & Collect module
/// 
/// Allows customers to select a pickup point/location for their order.
/// Displays a list of available pickup points with details.
class PointSelectorScreen extends StatefulWidget {
  /// Optional callback when a point is selected
  final Function(PickupPoint)? onPointSelected;

  /// List of available pickup points (can be loaded from config or Firestore)
  final List<PickupPoint>? pickupPoints;

  /// Currently selected point (if any)
  final PickupPoint? selectedPoint;

  const PointSelectorScreen({
    super.key,
    this.onPointSelected,
    this.pickupPoints,
    this.selectedPoint,
  });

  @override
  State<PointSelectorScreen> createState() => _PointSelectorScreenState();
}

class _PointSelectorScreenState extends State<PointSelectorScreen> {
  PickupPoint? _selectedPoint;
  late List<PickupPoint> _points;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.selectedPoint;
    
    // Use provided points or create default demo points
    _points = widget.pickupPoints ?? _getDefaultPoints();
  }

  List<PickupPoint> _getDefaultPoints() {
    // Default demo points - in production, these should come from Firestore
    // or restaurant configuration
    return [
      const PickupPoint(
        id: 'point_1',
        name: 'Restaurant Principal',
        address: '123 Rue de la Pizza, 75001 Paris',
        phoneNumber: '+33 1 23 45 67 89',
        openingHours: [
          'Lun-Ven: 11h00-14h00, 18h00-22h00',
          'Sam-Dim: 11h00-23h00',
        ],
        isAvailable: true,
        latitude: 48.8566,
        longitude: 2.3522,
      ),
      const PickupPoint(
        id: 'point_2',
        name: 'Point Relais Centre',
        address: '45 Avenue des Champs, 75008 Paris',
        phoneNumber: '+33 1 98 76 54 32',
        openingHours: [
          'Lun-Sam: 10h00-20h00',
          'Dim: Fermé',
        ],
        isAvailable: true,
        latitude: 48.8698,
        longitude: 2.3081,
      ),
      const PickupPoint(
        id: 'point_3',
        name: 'Annexe Nord',
        address: '78 Boulevard du Nord, 75018 Paris',
        phoneNumber: '+33 1 11 22 33 44',
        openingHours: [
          'Lun-Dim: 11h00-22h00',
        ],
        isAvailable: false, // Example of unavailable point
        latitude: 48.8922,
        longitude: 2.3444,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un point de retrait'),
        actions: [
          if (_selectedPoint != null)
            TextButton(
              onPressed: _confirmSelection,
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _points.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _points.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final point = _points[index];
                return _buildPointCard(point);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun point de retrait disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Veuillez contacter le restaurant',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(PickupPoint point) {
    final isSelected = _selectedPoint?.id == point.id;
    final isAvailable = point.isAvailable;

    return Card(
      elevation: isSelected ? 8 : 2,
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
        onTap: isAvailable
            ? () {
                setState(() {
                  _selectedPoint = point;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isAvailable ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isSelected ? Icons.location_on : Icons.location_on_outlined,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            point.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isAvailable) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Non disponible',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on, point.address),
                if (point.phoneNumber != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone, point.phoneNumber!),
                ],
                if (point.openingHours.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.access_time,
                    point.openingHours.join('\n'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmSelection() {
    if (_selectedPoint != null) {
      if (widget.onPointSelected != null) {
        widget.onPointSelected!(_selectedPoint!);
      }
      Navigator.of(context).pop(_selectedPoint);
    }
  }
}
