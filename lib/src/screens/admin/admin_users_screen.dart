// lib/src/screens/admin/admin_users_screen.dart
// Écran de gestion des utilisateurs (Admin)

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../core/constants.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();
  List<AppUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    await _userService.initialize();
    final users = await _userService.loadAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _showUserDialog({AppUser? user}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    String selectedRole = user?.role ?? UserRole.client;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? 'Nouvel Utilisateur' : 'Modifier Utilisateur'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                      hintText: 'Ex: Jean Dupont',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nom requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      hintText: 'ex@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: user == null, // Ne pas modifier l'email d'un utilisateur existant
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email requis';
                      }
                      if (!value.contains('@')) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (user == null)
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe *',
                        hintText: 'Minimum 6 caractères',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Minimum 6 caractères';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Rôle *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'client',
                        child: Text('Client'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Administrateur'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newUser = AppUser(
                    id: user?.id ?? const Uuid().v4(),
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    role: selectedRole,
                    isBlocked: user?.isBlocked ?? false,
                    createdAt: user?.createdAt ?? DateTime.now(),
                  );

                  bool success;
                  if (user == null) {
                    success = await _userService.addUser(newUser);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cet email existe déjà')),
                      );
                      return;
                    }
                  } else {
                    success = await _userService.updateUser(newUser);
                  }

                  if (success && context.mounted) {
                    Navigator.pop(context, true);
                  }
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _toggleUserBlock(AppUser user) async {
    final success = await _userService.toggleUserBlock(user.id);
    if (success) {
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(user.isBlocked ? 'Utilisateur débloqué' : 'Utilisateur bloqué'),
          ),
        );
      }
    }
  }

  Future<void> _showUserDetails(AppUser user) async {
    // Charger les commandes de l'utilisateur
    final allOrders = await _orderService.loadAllOrders();
    // Note: Dans une vraie app, on lierait les commandes aux utilisateurs via userId
    // Pour cette démo, on affiche toutes les commandes
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Rôle', user.role == UserRole.admin ? 'Administrateur' : 'Client'),
              _buildDetailRow('Statut', user.isBlocked ? 'Bloqué' : 'Actif'),
              _buildDetailRow('Créé le', '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'),
              const Divider(height: 24),
              Text(
                'Historique des commandes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${allOrders.length} commande(s) au total',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // Dans une vraie app, afficher les commandes spécifiques à cet utilisateur
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(AppUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'utilisateur "${user.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _userService.deleteUser(user.id);
      if (success) {
        _loadUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: AppTheme.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun utilisateur',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(VisualConstants.paddingMedium),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.role == UserRole.admin
                              ? Colors.amber
                              : AppTheme.primaryRed.withOpacity(0.2),
                          child: Icon(
                            user.role == UserRole.admin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: user.role == UserRole.admin
                                ? Colors.black87
                                : AppTheme.primaryRed,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (user.isBlocked) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BLOQUÉ',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email),
                            const SizedBox(height: 4),
                            Text(
                              user.role == UserRole.admin ? 'Administrateur' : 'Client',
                              style: TextStyle(
                                color: user.role == UserRole.admin ? Colors.amber[700] : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'view':
                                _showUserDetails(user);
                                break;
                              case 'edit':
                                _showUserDialog(user: user);
                                break;
                              case 'block':
                                _toggleUserBlock(user);
                                break;
                              case 'delete':
                                _deleteUser(user);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 20),
                                  SizedBox(width: 8),
                                  Text('Voir détails'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'block',
                              child: Row(
                                children: [
                                  Icon(
                                    user.isBlocked ? Icons.lock_open : Icons.lock,
                                    size: 20,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user.isBlocked ? 'Débloquer' : 'Bloquer'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Supprimer'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(),
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
