// lib/src/widgets/product_detail_modal.dart

import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductDetailModal extends StatefulWidget {
  final Product product;
  // Correction: La signature doit accepter la description personnalisée
  final Function(String? customDescription) onAddToCart;

  const ProductDetailModal({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailModal> createState() => _ProductDetailModalState();
}

class _ProductDetailModalState extends State<ProductDetailModal> {
  String? _selectedSize; // Exemple de personnalisation si non-menu
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialisation d'une taille par défaut si applicable
    if (widget.product.category == ProductCategory.pizza) {
      _selectedSize = 'Moyenne (30cm)';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // Simule le calcul du prix selon la taille
  double get _currentPrice {
    if (widget.product.category == ProductCategory.pizza && _selectedSize == 'Grande (40cm)') {
      return widget.product.price + 3.0;
    }
    return widget.product.price;
  }

  // Construit la description pour le panier
  String? _buildCustomDescription() {
    String description = '';
    
    // Ajout de la taille
    if (_selectedSize != null) {
      description += "Taille: $_selectedSize";
    }

    // Ajout des notes
    if (_notesController.text.isNotEmpty) {
      if (description.isNotEmpty) description += " | ";
      description += "Notes: ${_notesController.text}";
    }

    return description.isNotEmpty ? description : null;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(top: 16.0),
                  children: [
                    // Image et Nom
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          widget.product.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          
                          // Section Ingrédients de Base
                          if (widget.product.baseIngredients.isNotEmpty) ...[
                            Text(
                              'Ingrédients de Base',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: widget.product.baseIngredients
                                  .map((ing) => Chip(
                                        label: Text(ing),
                                        backgroundColor: Colors.red.shade50,
                                        labelStyle: const TextStyle(color: Color(0xFFB00020)),
                                      ))
                                  .toList(),
                            ),
                            const Divider(height: 30),
                          ],
                          
                          // Section Personnalisation (Exemple de sélection de taille)
                          if (widget.product.category == ProductCategory.pizza) ...[
                            Text(
                              'Choisir la Taille',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Column(
                              children: [
                                _buildRadioTile('Moyenne (30cm)', widget.product.price),
                                _buildRadioTile('Grande (40cm)', widget.product.price + 3.0),
                              ],
                            ),
                            const Divider(height: 30),
                          ],

                          // Section Notes Spéciales
                          Text(
                            'Notes Spéciales',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Ex: Sans oignons, bien cuite...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton Ajouter au Panier (Barre Fixe en bas)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Passage de la description personnalisée
                    widget.onAddToCart(_buildCustomDescription());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB00020),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Ajouter au Panier (${_currentPrice.toStringAsFixed(2)} €)',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadioTile(String title, double price) {
    return RadioListTile<String>(
      title: Text('$title (+${(price - widget.product.price).toStringAsFixed(2)} €)'),
      value: title,
      groupValue: _selectedSize,
      onChanged: (String? value) {
        setState(() {
          _selectedSize = value;
        });
      },
      activeColor: const Color(0xFFB00020),
    );
  }
}