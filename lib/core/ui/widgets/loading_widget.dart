import 'package:flutter/material.dart';

/// Loading widget with circular progress indicator
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  
  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// Full screen loading widget
class FullScreenLoading extends StatelessWidget {
  final String? message;
  
  const FullScreenLoading({
    super.key,
    this.message,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(message: message),
    );
  }
}






