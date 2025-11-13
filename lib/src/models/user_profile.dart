import 'order.dart'; // <<< NOUVEL IMPORT

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String address;
  final List<String> favoriteProducts;
  final List<Order> orderHistory; // CORRIGÉ: Utilise la classe Order
  final int loyaltyPoints;
  final String loyaltyLevel;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.address,
    required this.favoriteProducts,
    required this.orderHistory,
    this.loyaltyPoints = 0,
    this.loyaltyLevel = 'Bronze',
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? address,
    List<String>? favoriteProducts,
    List<Order>? orderHistory,
    int? loyaltyPoints,
    String? loyaltyLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      orderHistory: orderHistory ?? this.orderHistory,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
    );
  }

  // Conversion vers JSON pour Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'address': address,
      'favoriteProducts': favoriteProducts,
      'loyaltyPoints': loyaltyPoints,
      'loyaltyLevel': loyaltyLevel,
      // Note: orderHistory n'est pas stocké dans le profil, il est dans une collection séparée
    };
  }

  // Création depuis JSON (compatible Firestore)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String,
      address: json['address'] as String,
      favoriteProducts: (json['favoriteProducts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      orderHistory: [], // Les commandes sont chargées séparément
      loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
      loyaltyLevel: json['loyaltyLevel'] as String? ?? 'Bronze',
    );
  }

  // Profil initial mocké
  factory UserProfile.initial() {
    return UserProfile(
      id: 'user_1',
      name: 'Alexandre Dupont',
      email: 'alex.dupont@delizza.com',
      imageUrl: 'https://picsum.photos/200/200?user',
      address: '12 Rue de la Faim, 75000 Paris',
      favoriteProducts: [],
      orderHistory: [],
      loyaltyPoints: 0,
      loyaltyLevel: 'Bronze',
    );
  }
}