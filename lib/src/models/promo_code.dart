// lib/src/models/promo_code.dart
// Modèle pour les codes promo

class PromoCode {
  final String id;
  final String code;
  final double discount; // Réduction en pourcentage (10 = 10%)
  final double? fixedDiscount; // Réduction fixe en euros
  final DateTime? expiryDate;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final String? applicableToProductId; // null = applicable à tous

  PromoCode({
    required this.id,
    required this.code,
    this.discount = 0,
    this.fixedDiscount,
    this.expiryDate,
    this.usageLimit,
    this.usageCount = 0,
    this.isActive = true,
    this.applicableToProductId,
  });

  bool get isValid {
    if (!isActive) return false;
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    return true;
  }

  double calculateDiscount(double amount) {
    if (fixedDiscount != null) {
      return fixedDiscount!;
    }
    return amount * (discount / 100);
  }

  PromoCode copyWith({
    String? id,
    String? code,
    double? discount,
    double? fixedDiscount,
    DateTime? expiryDate,
    int? usageLimit,
    int? usageCount,
    bool? isActive,
    String? applicableToProductId,
  }) {
    return PromoCode(
      id: id ?? this.id,
      code: code ?? this.code,
      discount: discount ?? this.discount,
      fixedDiscount: fixedDiscount ?? this.fixedDiscount,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      isActive: isActive ?? this.isActive,
      applicableToProductId: applicableToProductId ?? this.applicableToProductId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'fixedDiscount': fixedDiscount,
      'expiryDate': expiryDate?.toIso8601String(),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'applicableToProductId': applicableToProductId,
    };
  }

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] as String,
      code: json['code'] as String,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      fixedDiscount: (json['fixedDiscount'] as num?)?.toDouble(),
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      applicableToProductId: json['applicableToProductId'] as String?,
    );
  }
}
