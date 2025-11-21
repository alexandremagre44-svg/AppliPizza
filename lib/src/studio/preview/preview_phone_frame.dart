// lib/src/studio/preview/preview_phone_frame.dart
// Professional smartphone frame widget for preview

import 'package:flutter/material.dart';

/// Professional smartphone frame for preview
class PreviewPhoneFrame extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const PreviewPhoneFrame({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate responsive dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Use 16:9 ratio for narrow screens, 19.5:9 for wider screens
    final aspectRatio = screenWidth > 1200 ? 19.5 / 9 : 16 / 9;
    
    // Calculate frame dimensions
    final frameWidth = width ?? (screenWidth > 1200 ? 375.0 : 360.0);
    final frameHeight = height ?? (frameWidth * aspectRatio);

    return Container(
      width: frameWidth,
      height: frameHeight,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Phone header (notch area)
          _buildPhoneHeader(),
          
          // Phone body (scrollable content)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              child: Container(
                color: Colors.white,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build phone header with notch
  Widget _buildPhoneHeader() {
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Status bar icons (left side)
          Positioned(
            left: 16,
            top: 8,
            child: Row(
              children: [
                Icon(
                  Icons.signal_cellular_4_bar,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.wifi,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
              ],
            ),
          ),
          
          // Notch (center)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              width: 140,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          
          // Battery and time (right side)
          Positioned(
            right: 16,
            top: 8,
            child: Row(
              children: [
                Text(
                  '12:00',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.battery_full,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
