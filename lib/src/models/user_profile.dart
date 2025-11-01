import 'order.dart'; // <<< NOUVEL IMPORT

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final String address;
  final List<String> favoriteProducts;
  final List<Order> orderHistory; // CORRIGÉ: Utilise la classe Order

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.address,
    required this.favoriteProducts,
    required this.orderHistory,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? address,
    List<String>? favoriteProducts,
    List<Order>? orderHistory, // CORRIGÉ
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      address: address ?? this.address,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      orderHistory: orderHistory ?? this.orderHistory, // CORRIGÉ
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
    );
  }
}