import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorWidegt extends StatelessWidget {
    final String message;
  final VoidCallback onRetry;
  const ErrorWidegt({super.key, required this.message, required this.onRetry});


  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('failed_to_load'.tr,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr),
              ),
            ],
          ),
        ),
      );
}


  