// Test pour FirestoreProductService
import 'package:flutter_test/flutter_test.dart';
import 'package:pizza_delizza/src/services/firestore_product_service.dart';

void main() {
  group('FirestoreProductService Tests', () {
    test('MockFirestoreProductService devrait implémenter getAllProducts', () async {
      final service = MockFirestoreProductService();
      
      // Verify getAllProducts method exists and returns empty list
      final products = await service.getAllProducts();
      
      expect(products, isNotNull);
      expect(products, isEmpty);
    });

    test('MockFirestoreProductService devrait implémenter loadAllProducts', () async {
      final service = MockFirestoreProductService();
      
      // Verify loadAllProducts method exists and returns empty list
      final products = await service.loadAllProducts();
      
      expect(products, isNotNull);
      expect(products, isEmpty);
    });

    test('createFirestoreProductService devrait retourner une instance', () {
      final service = createFirestoreProductService();
      
      expect(service, isNotNull);
      expect(service, isA<FirestoreProductService>());
    });

    test('getAllProducts et loadAllProducts devraient être cohérents', () async {
      final service = MockFirestoreProductService();
      
      final products1 = await service.getAllProducts();
      final products2 = await service.loadAllProducts();
      
      // Both methods should return the same result
      expect(products1.length, products2.length);
    });
  });
}
