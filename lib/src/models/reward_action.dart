// lib/src/models/reward_action.dart
// Core reward system models - RewardType enum and RewardAction class

/// Types of rewards that can be granted
/// 
/// This enum defines all possible reward types in the system.
/// Used by roulette, loyalty, and promotional campaigns.
enum RewardType {
  /// Bonus loyalty points
  bonusPoints('bonus_points'),
  
  /// Percentage discount (e.g., 10% off)
  percentageDiscount('percentage_discount'),
  
  /// Fixed amount discount (e.g., 5€ off)
  fixedDiscount('fixed_discount'),
  
  /// Specific product for free (exact product ID)
  freeProduct('free_product'),
  
  /// Free product from a category (e.g., classic pizzas)
  freeCategory('free_category'),
  
  /// Free drink
  freeDrink('free_drink'),
  
  /// Any pizza for free
  freeAnyPizza('free_any_pizza'),
  
  /// Custom reward (placeholder for future use)
  custom('custom');

  const RewardType(this.value);
  final String value;

  /// Convert from string to enum
  static RewardType fromString(String value) {
    return RewardType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RewardType.custom,
    );
  }
}

/// Logical representation of a reward action
/// 
/// This class describes what the reward does, without being tied to a specific
/// ticket or user. It's the "blueprint" of the reward.
/// 
/// Examples:
/// - 20% discount: RewardAction(type: percentageDiscount, percentage: 20)
/// - Free pizza: RewardAction(type: freeAnyPizza, categoryId: 'Pizza')
/// - 5€ off: RewardAction(type: fixedDiscount, amount: 5.0)
/// - Bonus points: RewardAction(type: bonusPoints, points: 100)
class RewardAction {
  /// Type of reward
  final RewardType type;
  
  /// Points value for bonus_points (e.g., 100 for +100 points)
  final int? points;
  
  /// Percentage value for percentage_discount (e.g., 20 for 20%)
  final double? percentage;
  
  /// Amount value for fixed_discount (e.g., 5.0 for 5€)
  final double? amount;
  
  /// Specific product ID for free_product or free_drink
  final String? productId;
  
  /// Category ID for free_category or free_any_pizza
  final String? categoryId;
  
  /// Source of the reward ("roulette", "loyalty", "promo")
  final String? source;
  
  /// Display label (e.g., "-20%", "Pizza offerte", "Boisson gratuite")
  final String? label;
  
  /// Human-readable description
  final String? description;

  const RewardAction({
    required this.type,
    this.points,
    this.percentage,
    this.amount,
    this.productId,
    this.categoryId,
    this.source,
    this.label,
    this.description,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      if (points != null) 'points': points,
      if (percentage != null) 'percentage': percentage,
      if (amount != null) 'amount': amount,
      if (productId != null) 'productId': productId,
      if (categoryId != null) 'categoryId': categoryId,
      if (source != null) 'source': source,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
    };
  }

  /// Create from Firestore map
  factory RewardAction.fromMap(Map<String, dynamic> map) {
    return RewardAction(
      type: RewardType.fromString(map['type'] as String? ?? 'custom'),
      points: map['points'] as int?,
      percentage: (map['percentage'] as num?)?.toDouble(),
      amount: (map['amount'] as num?)?.toDouble(),
      productId: map['productId'] as String?,
      categoryId: map['categoryId'] as String?,
      source: map['source'] as String?,
      label: map['label'] as String?,
      description: map['description'] as String?,
    );
  }

  /// Create a copy with modified fields
  RewardAction copyWith({
    RewardType? type,
    int? points,
    double? percentage,
    double? amount,
    String? productId,
    String? categoryId,
    String? source,
    String? label,
    String? description,
  }) {
    return RewardAction(
      type: type ?? this.type,
      points: points ?? this.points,
      percentage: percentage ?? this.percentage,
      amount: amount ?? this.amount,
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      source: source ?? this.source,
      label: label ?? this.label,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'RewardAction(type: ${type.value}, label: $label)';
  }
}
