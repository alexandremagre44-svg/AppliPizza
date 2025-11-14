// lib/src/staff_tablet/screens/staff_tablet_pin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/staff_tablet_auth_provider.dart';

class StaffTabletPinScreen extends ConsumerStatefulWidget {
  const StaffTabletPinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StaffTabletPinScreen> createState() => _StaffTabletPinScreenState();
}

class _StaffTabletPinScreenState extends ConsumerState<StaffTabletPinScreen> {
  String _enteredPin = '';
  bool _isError = false;

  void _onNumberPressed(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
        _isError = false;
      });

      // Auto-submit when 4 digits entered
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _isError = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final authNotifier = ref.read(staffTabletAuthProvider.notifier);
    final isValid = await authNotifier.authenticate(_enteredPin);

    if (isValid) {
      if (mounted) {
        context.go('/staff-tablet/catalog');
      }
    } else {
      setState(() {
        _isError = true;
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Title
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.orange[700],
              ),
              const SizedBox(height: 24),
              const Text(
                'Mode Caisse',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entrez le code PIN',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 48),

              // PIN dots display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? (_isError ? Colors.red : Colors.orange[700])
                          : Colors.grey[700],
                      border: Border.all(
                        color: _isError ? Colors.red : Colors.grey[600]!,
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              
              if (_isError) ...[
                const SizedBox(height: 16),
                Text(
                  'Code PIN incorrect',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 16,
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // Number pad
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...[1, 2, 3, 4, 5, 6, 7, 8, 9].map((num) => _buildNumberButton(num.toString())),
                  const SizedBox(), // Empty space
                  _buildNumberButton('0'),
                  _buildBackspaceButton(),
                ],
              ),

              const SizedBox(height: 32),

              // Back to home button
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(
                  'Retour à l\'accueil',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return ElevatedButton(
      onPressed: () => _onNumberPressed(number),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return ElevatedButton(
      onPressed: _onBackspace,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.orange[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      child: const Icon(
        Icons.backspace_outlined,
        size: 28,
      ),
    );
  }
}
