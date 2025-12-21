import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schools listing page (Learning Schools)
class SchoolsPage extends ConsumerWidget {
  const SchoolsPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Schools'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Choose Your Path',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a school to begin your Hindu learning journey',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Mock schools for now (will connect to API later)
              _buildSchoolCard(
                context,
                title: 'Shruti & Smriti Studies',
                description: 'Vedas, Upanishads, Bhagavad Gita, Itihasas, Puranas',
                icon: Icons.book,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildSchoolCard(
                context,
                title: 'Applied Dharma',
                description: 'Karma, Bhakti, Jnana Yoga, Leadership, Ethics',
                icon: Icons.self_improvement,
                color: Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildSchoolCard(
                context,
                title: 'Hindu Civilization & Thinkers',
                description: 'Ancient Gurus, Bhakti Movement, Freedom Fighters',
                icon: Icons.history_edu,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildSchoolCard(
                context,
                title: 'Sadhana & Lifestyle',
                description: 'Meditation, Yoga, Sanskrit, Hindu Rituals',
                icon: Icons.spa,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSchoolCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to courses page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening $title...')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

