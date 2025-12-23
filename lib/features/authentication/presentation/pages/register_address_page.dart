import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/register_address_form.dart';

/// Registration Address Page (Step 2: Address Information)
class RegisterAddressPage extends ConsumerWidget {
  final Map<String, dynamic> biographicData;
  
  const RegisterAddressPage({
    super.key,
    required this.biographicData,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Address Information'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              // Registration Address Form (Step 2)
              RegisterAddressForm(biographicData: biographicData),
            ],
          ),
        ),
      ),
    );
  }
}





