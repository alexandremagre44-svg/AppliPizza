// lib/src/models/reward_ticket.dart
// Reward ticket model - Stored in Firestore as user's reward

import 'reward_action.dart';

/// A reward ticket that is stored in Firestore
/// 
/// Firestore structure:
/// Collection: users/{userId}/rewardTickets/{ticketId}
/// 
/// Each ticket represents a reward that has been granted to a user.
/// Tickets have an expiration date and can only be used once.
class RewardTicket {
  /// Unique ticket ID
  final String id;
  
  /// User ID who owns this ticket
  final String userId;
  
  /// The reward action (what the ticket grants)
  final RewardAction action;
  
  /// When the ticket was created
  final DateTime createdAt;
  
  /// When the ticket expires
  final DateTime expiresAt;
  
  /// Whether the ticket has been used
  final bool isUsed;
  
  /// When the ticket was used (null if not used)
  final DateTime? usedAt;

  const RewardTicket({
    required this.id,
    required this.userId,
    required this.action,
    required this.createdAt,
    required this.expiresAt,
    this.isUsed = false,
    this.usedAt,
  });

  /// Check if the ticket is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if the ticket is active (not used and not expired)
  bool get isActive => !isExpired && !isUsed;

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      ...action.toMap(), // Flatten action fields
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isUsed': isUsed,
      if (usedAt != null) 'usedAt': usedAt!.toIso8601String(),
    };
  }

  /// Create from Firestore map
  factory RewardTicket.fromMap(Map<String, dynamic> map, String docId) {
    return RewardTicket(
      id: docId,
      userId: map['userId'] as String,
      action: RewardAction.fromMap(map),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDateTime(map['expiresAt']) ?? DateTime.now().add(const Duration(days: 30)),
      isUsed: map['isUsed'] as bool? ?? false,
      usedAt: _parseDateTime(map['usedAt']),
    );
  }

  /// Parse DateTime from various formats (ISO8601 string or Firestore Timestamp)
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    // Handle ISO8601 string
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $e');
        return null;
      }
    }
    
    // Handle Firestore Timestamp
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (e) {
      print('Error converting Timestamp to DateTime: $e');
      return null;
    }
  }

  /// Create a copy with modified fields
  RewardTicket copyWith({
    String? id,
    String? userId,
    RewardAction? action,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isUsed,
    DateTime? usedAt,
  }) {
    return RewardTicket(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  @override
  String toString() {
    return 'RewardTicket(id: $id, action: ${action.label}, isActive: $isActive)';
  }
}
