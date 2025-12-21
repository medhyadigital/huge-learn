import 'package:flutter/material.dart';
import '../../error/failures.dart';
import '../../utils/extensions.dart';

/// Error widget to display failures
class ErrorDisplayWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;
  
  const ErrorDisplayWidget({
    super.key,
    required this.failure,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              failure.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  IconData _getErrorIcon() {
    if (failure is NetworkFailure) {
      return Icons.wifi_off;
    } else if (failure is ServerFailure) {
      return Icons.error_outline;
    } else if (failure is AuthFailure) {
      return Icons.lock_outline;
    } else {
      return Icons.error_outline;
    }
  }
  
  String _getErrorTitle() {
    if (failure is NetworkFailure) {
      return 'No Internet Connection';
    } else if (failure is ServerFailure) {
      return 'Server Error';
    } else if (failure is AuthFailure) {
      return 'Authentication Error';
    } else {
      return 'Something Went Wrong';
    }
  }
}




