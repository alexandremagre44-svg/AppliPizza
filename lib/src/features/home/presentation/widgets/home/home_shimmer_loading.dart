// lib/src/widgets/home/home_shimmer_loading.dart
// Shimmer loading effect that mimics the home page structure

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/theme/app_theme.dart';

/// Shimmer loading widget that mimics the home page structure
/// Shows animated placeholder for Hero, Banner, and blocks
class HomeShimmerLoading extends StatelessWidget {
  const HomeShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: AppSpacing.lg),
          
          // Hero banner placeholder
          _buildShimmerBox(
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            borderRadius: AppRadius.cardLarge,
          ),
          
          SizedBox(height: AppSpacing.xxl),
          
          // Section header placeholder
          _buildShimmerBox(
            height: 24,
            width: 150,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Product grid placeholders (2 columns)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => _buildProductCardShimmer(),
            ),
          ),
          
          SizedBox(height: AppSpacing.xxl),
          
          // Another section
          _buildShimmerBox(
            height: 24,
            width: 180,
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Category shortcuts placeholders
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: _buildShimmerBox(
                  width: 80,
                  height: 100,
                  borderRadius: AppRadius.card,
                ),
              ),
            ),
          ),
          
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildProductCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 8),
                  // Price placeholder
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBox({
    required double height,
    double? width,
    EdgeInsets? margin,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}
