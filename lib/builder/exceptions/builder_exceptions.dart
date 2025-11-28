// lib/builder/exceptions/builder_exceptions.dart
// Custom exceptions for Builder B3 system

/// Exception thrown when a page cannot be found
/// 
/// Use this exception when:
/// - Page doesn't exist in Firestore  
/// - Page should fallback to legacy screen (widget fallback)
/// 
/// Note: [BuilderPageId.fromString] now throws [FormatException] instead
/// for unknown pageKeys. Use [BuilderPageId.tryFromString] for nullable result.
/// 
/// This exception is specifically for page resolution failures where
/// the caller should handle by showing a fallback widget.
/// 
/// See also: [BuilderPageException] for general Builder errors
class PageNotFoundException implements Exception {
  final String message;
  final String? pageKey;

  const PageNotFoundException(this.message, {this.pageKey});

  @override
  String toString() => 'PageNotFoundException: $message${pageKey != null ? ' (pageKey: $pageKey)' : ''}';
}

/// Exception thrown when a Builder page operation fails
/// 
/// Use this exception for general Builder errors such as:
/// - Failed to load page from Firestore (network/permission issues)
/// - Failed to save page configuration
/// - Failed to publish page
/// 
/// For page resolution failures (page not found), use [PageNotFoundException] instead.
class BuilderPageException implements Exception {
  final String message;
  final String? pageId;

  const BuilderPageException(this.message, {this.pageId});

  @override
  String toString() => 'BuilderPageException: $message${pageId != null ? ' (pageId: $pageId)' : ''}';
}

/// Exception thrown when trying to configure less than 2 pages in bottom bar
class MinimumBottomNavItemsException implements Exception {
  final String message;

  const MinimumBottomNavItemsException([
    this.message = 'Il doit y avoir au moins 2 pages dans la barre inférieure.',
  ]);

  @override
  String toString() => 'MinimumBottomNavItemsException: $message';
}

/// Exception thrown when trying to use a bottomNavIndex that's already taken
class BottomNavIndexConflictException implements Exception {
  final String message;
  final int conflictingIndex;
  final String? conflictingPageName;

  BottomNavIndexConflictException(
    this.conflictingIndex, [
    this.conflictingPageName,
  ]) : message = conflictingPageName != null
            ? 'Cette position est déjà utilisée par une autre page ($conflictingPageName).'
            : 'Cette position est déjà utilisée par une autre page.';

  @override
  String toString() => 'BottomNavIndexConflictException: $message';
}
