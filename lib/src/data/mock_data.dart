// lib/src/data/mock_data.dart

import '../models/product.dart';

// ===============================================
// INGRÉDIENTS (pour la personnalisation future)
// ===============================================

final List<Ingredient> mockIngredients = [
  Ingredient(id: 'ing_mozza', name: 'Mozzarella Fraîche', extraCost: 1.50),
  Ingredient(id: 'ing_cheddar', name: 'Cheddar', extraCost: 1.00),
  Ingredient(id: 'ing_oignon', name: 'Oignons Rouges', extraCost: 0.50),
  Ingredient(id: 'ing_champignons', name: 'Champignons', extraCost: 0.75),
  Ingredient(id: 'ing_jambon', name: 'Jambon Supérieur', extraCost: 1.25),
  Ingredient(id: 'ing_poulet', name: 'Poulet Rôti', extraCost: 2.00),
  Ingredient(id: 'ing_chorizo', name: 'Chorizo Piquant', extraCost: 1.75),
  Ingredient(id: 'ing_olives', name: 'Olives Noires', extraCost: 0.50),
];

// ===============================================
// PRODUITS & MENUS
// ===============================================

final List<Product> mockProducts = [
  // --- PIZZAS CLASSIQUES ---
  Product(
    id: 'p1',
    name: 'Margherita Classique',
    description: 'Tomate, Mozzarella, Origan.',
    price: 12.50,
    imageUrl: 'https://images.unsplash.com/photo-1574126154517-d1e0d89ef734?q=80&w=200&h=200&fit=crop',
    category: 'Pizza',
    baseIngredients: ['Tomate', 'Mozzarella', 'Origan'],
  ),
  Product(
    id: 'p2',
    name: 'Reine',
    description: 'Tomate, Mozzarella, Jambon, Champignons.',
    price: 14.90,
    imageUrl: 'https://images.unsplash.com/photo-1593532359400-b28668c222ff?q=80&w=200&h=200&fit=crop',
    category: 'Pizza',
    baseIngredients: ['Tomate', 'Mozzarella', 'Jambon', 'Champignons'],
  ),
  Product(
    id: 'p3',
    name: 'Végétarienne',
    description: 'Tomate, Mozzarella, Oignons, Poivrons, Olives.',
    price: 13.50,
    imageUrl: 'https://images.unsplash.com/photo-1565299624942-4c27a20c3a28?q=80&w=200&h=200&fit=crop',
    category: 'Pizza',
    baseIngredients: ['Tomate', 'Mozzarella', 'Oignons', 'Poivrons', 'Olives'],
  ),
  Product(
    id: 'p4',
    name: '4 Fromages',
    description: 'Base Crème fraîche, Mozzarella, Chèvre, Emmental, Roquefort.',
    price: 16.00,
    imageUrl: 'https://images.unsplash.com/photo-1628840042767-3e64f20e408c?q=80&w=200&h=200&fit=crop',
    category: 'Pizza',
    baseIngredients: ['Crème fraîche', 'Mozzarella', 'Chèvre', 'Emmental', 'Roquefort'],
  ),
  Product(
    id: 'p5',
    name: 'Chicken Barbecue',
    description: 'Sauce BBQ, Mozzarella, Poulet rôti, Oignons, Poivrons.',
    price: 15.50,
    imageUrl: 'https://images.unsplash.com/photo-1594002636049-9828d5045a90?q=80&w=200&h=200&fit=crop',
    category: 'Pizza',
    baseIngredients: ['Sauce BBQ', 'Mozzarella', 'Poulet rôti', 'Oignons', 'Poivrons'],
  ),
  Product(
    id: 'p6',
    name: 'Pepperoni',
    description: 'Tomate, Mozzarella, Double Pepperoni.',
    price: 14.90,
    imageUrl: 'https://images.unsplash.com/photo-1588315024476-8092a83e0618?q=80&w=200&h=200&fit=crop',
    category: 'Pizza',
    baseIngredients: ['Tomate', 'Mozzarella', 'Pepperoni'],
  ),

  // --- BOISSONS ---
  Product(
    id: 'd1',
    name: 'Coca-Cola (33cl)',
    description: 'Boisson gazeuse rafraîchissante.',
    price: 2.50,
    imageUrl: 'https://images.unsplash.com/photo-1625983790518-e25f78c8574d?q=80&w=200&h=200&fit=crop',
    category: 'Boissons',
  ),
  Product(
    id: 'd2',
    name: 'Eau Minérale (50cl)',
    description: 'Bouteille d\'eau de source.',
    price: 1.50,
    imageUrl: 'https://images.unsplash.com/photo-1534273292415-46b5d928424a?q=80&w=200&h=200&fit=crop',
    category: 'Boissons',
  ),
  Product(
    id: 'd3',
    name: 'Jus d\'Orange (33cl)',
    description: 'Jus de fruits 100% pur jus.',
    price: 2.80,
    imageUrl: 'https://images.unsplash.com/photo-1507727197022-b94f09d8d641?q=80&w=200&h=200&fit=crop',
    category: 'Boissons',
  ),
  
  // --- DESSERTS ---
  Product(
    id: 'ds1',
    name: 'Tiramisu Maison',
    description: 'Le classique italien au café et mascarpone.',
    price: 4.50,
    imageUrl: 'https://images.unsplash.com/photo-1535450849646-619a97621c8b?q=80&w=200&h=200&fit=crop',
    category: 'Desserts',
  ),
  Product(
    id: 'ds2',
    name: 'Mousse au Chocolat',
    description: 'Mousse légère au chocolat noir intense.',
    price: 3.90,
    imageUrl: 'https://images.unsplash.com/photo-1572979607823-149b1a03f8a0?q=80&w=200&h=200&fit=crop',
    category: 'Desserts',
  ),

  // --- MENUS ---
  Product(
    id: 'm1',
    name: 'Menu Duo',
    description: '1 grande pizza au choix et 1 boisson.',
    price: 18.90,
    imageUrl: 'https://images.unsplash.com/photo-1517441656819-21503e05a8d9?q=80&w=200&h=200&fit=crop',
    category: 'Menus',
    isMenu: true,
    pizzaCount: 1, 
    drinkCount: 1, 
  ),
  Product(
    id: 'm2',
    name: 'Menu Famille',
    description: '2 grandes pizzas au choix et 2 boissons.',
    price: 34.90,
    imageUrl: 'https://images.unsplash.com/photo-1542838132-84175b92750e?q=80&w=200&h=200&fit=crop',
    category: 'Menus',
    isMenu: true,
    pizzaCount: 2, 
    drinkCount: 2, 
  ),
  Product(
    id: 'm3',
    name: 'Menu Solo',
    description: '1 pizza individuelle et un dessert au choix.',
    price: 14.00,
    imageUrl: 'https://images.unsplash.com/photo-1582239401830-4e32e82b7b05?q=80&w=200&h=200&fit=crop',
    category: 'Menus',
    isMenu: true,
    pizzaCount: 1, 
    drinkCount: 0, // 0 boisson (on gèrera le dessert plus tard)
  ),
];