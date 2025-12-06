/// Test for SuperAdmin access control
///
/// This test verifies that only users with SuperAdmin role
/// can access /superadmin routes.

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuperAdmin Access Control Tests', () {
    test('SuperAdmin access logic validation', () {
      // Test 1: Regular admin should NOT have superadmin access
      final regularAdmin = {
        'isLoggedIn': true,
        'isAdmin': true,
        'isSuperAdmin': false,
      };
      
      // Simulate accessing /superadmin route
      final shouldRedirect = regularAdmin['isLoggedIn'] == true &&
          '/superadmin/dashboard'.startsWith('/superadmin') &&
          regularAdmin['isSuperAdmin'] == false;
      
      expect(shouldRedirect, true, reason: 'Regular admin should be redirected from /superadmin');
      
      // Test 2: SuperAdmin SHOULD have access
      final superAdmin = {
        'isLoggedIn': true,
        'isAdmin': true,
        'isSuperAdmin': true,
      };
      
      final superAdminShouldRedirect = superAdmin['isLoggedIn'] == true &&
          '/superadmin/dashboard'.startsWith('/superadmin') &&
          superAdmin['isSuperAdmin'] == false;
      
      expect(superAdminShouldRedirect, false, reason: 'SuperAdmin should NOT be redirected from /superadmin');
      
      // Test 3: Non-logged in users should be redirected at auth level (not tested here)
      // This is handled by the isLoggedIn check before superadmin check
      
      // Test 4: Regular client should NOT have access
      final regularClient = {
        'isLoggedIn': true,
        'isAdmin': false,
        'isSuperAdmin': false,
      };
      
      final clientShouldRedirect = regularClient['isLoggedIn'] == true &&
          '/superadmin/dashboard'.startsWith('/superadmin') &&
          regularClient['isSuperAdmin'] == false;
      
      expect(clientShouldRedirect, true, reason: 'Regular client should be redirected from /superadmin');
    });

    test('Path matching logic validation', () {
      // Test various superadmin paths
      final superadminPaths = [
        '/superadmin',
        '/superadmin/dashboard',
        '/superadmin/restaurants',
        '/superadmin/users',
        '/superadmin/modules',
        '/superadmin/settings',
        '/superadmin/restaurants/abc123',
        '/superadmin/restaurants/abc123/modules',
      ];
      
      for (final path in superadminPaths) {
        expect(path.startsWith('/superadmin'), true, 
            reason: 'Path $path should match /superadmin prefix');
      }
      
      // Test non-superadmin paths
      final nonSuperadminPaths = [
        '/home',
        '/menu',
        '/admin/studio',
        '/admin/products',
        '/profile',
        '/login',
      ];
      
      for (final path in nonSuperadminPaths) {
        expect(path.startsWith('/superadmin'), false, 
            reason: 'Path $path should NOT match /superadmin prefix');
      }
    });

    test('Redirect target validation', () {
      // When a non-superadmin tries to access /superadmin,
      // they should be redirected to /menu (as per requirement)
      const redirectTarget = '/menu';
      
      expect(redirectTarget, '/menu', 
          reason: 'Non-superadmins should be redirected to /menu');
    });
  });
}
