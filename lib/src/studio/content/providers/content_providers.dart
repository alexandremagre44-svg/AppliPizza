// lib/src/studio/content/providers/content_providers.dart
// Riverpod providers for home content management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_section_model.dart';
import '../models/featured_products_model.dart';
import '../models/category_override_model.dart';
import '../models/product_override_model.dart';
import '../services/content_section_service.dart';
import '../services/featured_products_service.dart';
import '../services/category_override_service.dart';
import '../services/product_override_service.dart';

// Services
final contentSectionServiceProvider = Provider((ref) => ContentSectionService());
final featuredProductsServiceProvider = Provider((ref) => FeaturedProductsService());
final categoryOverrideServiceProvider = Provider((ref) => CategoryOverrideService());
final productOverrideServiceProvider = Provider((ref) => ProductOverrideService());

// Custom sections
final customSectionsProvider = StreamProvider<List<ContentSection>>((ref) {
  final service = ref.watch(contentSectionServiceProvider);
  return FirebaseFirestore.instance
      .collection(ContentSectionService.collectionName)
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ContentSection.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

final customSectionsFutureProvider = FutureProvider<List<ContentSection>>((ref) async {
  final service = ref.watch(contentSectionServiceProvider);
  return await service.getAllSections();
});

// Featured products
final featuredProductsProvider = StreamProvider<FeaturedProductsConfig>((ref) {
  final service = ref.watch(featuredProductsServiceProvider);
  return FirebaseFirestore.instance
      .collection(FeaturedProductsService.collectionName)
      .doc(FeaturedProductsService.documentId)
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return FeaturedProductsConfig.initial();
        return FeaturedProductsConfig.fromJson({...snapshot.data()!, 'id': snapshot.id});
      });
});

final featuredProductsFutureProvider = FutureProvider<FeaturedProductsConfig>((ref) async {
  final service = ref.watch(featuredProductsServiceProvider);
  return await service.getConfig();
});

// Category overrides
final categoryOverridesProvider = StreamProvider<List<CategoryOverride>>((ref) {
  final service = ref.watch(categoryOverrideServiceProvider);
  return FirebaseFirestore.instance
      .collection(CategoryOverrideService.collectionName)
      .orderBy('order')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => CategoryOverride.fromJson(doc.data()))
          .toList());
});

final categoryOverridesFutureProvider = FutureProvider<List<CategoryOverride>>((ref) async {
  final service = ref.watch(categoryOverrideServiceProvider);
  return await service.getAllOverrides();
});

// Product overrides
final productOverridesProvider = StreamProvider<List<ProductOverride>>((ref) {
  final service = ref.watch(productOverrideServiceProvider);
  return FirebaseFirestore.instance
      .collection(ProductOverrideService.collectionName)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProductOverride.fromJson(doc.data()))
          .toList());
});

final productOverridesFutureProvider = FutureProvider<List<ProductOverride>>((ref) async {
  final service = ref.watch(productOverrideServiceProvider);
  return await service.getAllOverrides();
});

// Product overrides by category
final productOverridesByCategoryProvider = FutureProvider.family<List<ProductOverride>, String>((ref, categoryId) async {
  final service = ref.watch(productOverrideServiceProvider);
  return await service.getOverridesForCategory(categoryId);
});
