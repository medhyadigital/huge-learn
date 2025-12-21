import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

/// Registration Address Information Form (Step 2)
class RegisterAddressForm extends ConsumerStatefulWidget {
  final Map<String, dynamic> biographicData;
  
  const RegisterAddressForm({
    super.key,
    required this.biographicData,
  });
  
  @override
  ConsumerState<RegisterAddressForm> createState() => _RegisterAddressFormState();
}

class _RegisterAddressFormState extends ConsumerState<RegisterAddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _referralCodeController = TextEditingController();
  
  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    _referralCodeController.dispose();
    super.dispose();
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authNotifier = ref.read(authProvider.notifier);
    
    // Combine biographic and address data
    final success = await authNotifier.register(
      name: widget.biographicData['name'] as String,
      email: widget.biographicData['email'] as String,
      phone: widget.biographicData['phone'] as String,
      password: widget.biographicData['password'] as String,
      confirmPassword: widget.biographicData['confirmPassword'] as String,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      stateParam: _stateController.text.trim(),
      country: _countryController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      dateOfBirth: widget.biographicData['dateOfBirth'] as String,
      gender: widget.biographicData['gender'] as String,
      occupation: widget.biographicData['occupation'] as String?,
      referralCode: _referralCodeController.text.trim().isEmpty 
          ? null 
          : _referralCodeController.text.trim(),
      // recaptchaToken: null, // TODO: Add reCAPTCHA
      // emailOTP: null, // TODO: Add OTP verification
    );
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );
      context.go('/home');
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Registration failed. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step indicator
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Step 2 of 2: Address Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Address field
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address *',
              hintText: 'Enter your address',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          // City field
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City *',
              hintText: 'Enter your city',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          // State field
          TextFormField(
            controller: _stateController,
            decoration: const InputDecoration(
              labelText: 'State *',
              hintText: 'Enter your state',
              prefixIcon: Icon(Icons.map_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your state';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          // Country field
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country *',
              hintText: 'Enter your country',
              prefixIcon: Icon(Icons.public_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your country';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          // PIN Code field
          TextFormField(
            controller: _pinCodeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'PIN Code *',
              hintText: 'Enter your PIN code',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your PIN code';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          // Referral Code field (optional)
          TextFormField(
            controller: _referralCodeController,
            decoration: const InputDecoration(
              labelText: 'Referral Code (Optional)',
              hintText: 'Enter referral code if you have one',
              prefixIcon: Icon(Icons.card_giftcard_outlined),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          // Back button
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 72),
            ),
            child: const Text(
              'BACK',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Register button
          ElevatedButton(
            onPressed: authState.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 72),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}


