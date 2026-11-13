import 'package:flutter/material.dart';

/// Standardized loading / error / empty states. Use for every async screen.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.value,
    required this.builder,
    this.onRetry,
    this.emptyMessage = 'Nothing here yet',
  });

  final AsyncSnapshot<T> value;
  final Widget Function(T) builder;
  final VoidCallback? onRetry;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (value.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (value.hasError) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 40),
          const SizedBox(height: 8),
          Text('Something went wrong'),
          if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
    }
    if (!value.hasData || (value.data is List && (value.data as List).isEmpty)) {
      return Center(child: Text(emptyMessage));
    }
    return builder(value.data as T);
  }
}
