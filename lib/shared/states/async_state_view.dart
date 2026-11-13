import 'package:flutter/material.dart';
import '../components/app_button.dart';

enum AsyncStatus { loading, empty, error, offline, data }

class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.status,
    required this.builder,
    this.onRetry,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyAction,
    this.errorMessage = 'Something went wrong',
  });

  final AsyncStatus status;
  final WidgetBuilder builder;
  final VoidCallback? onRetry;
  final String emptyTitle;
  final String? emptyMessage;
  final IconData emptyIcon;
  final Widget? emptyAction;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AsyncStatus.data:
        return builder(context);
      case AsyncStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case AsyncStatus.offline:
        return _Message(
          icon: Icons.cloud_off_outlined,
          title: "You're offline",
          message: 'Changes will sync when you reconnect.',
          action: onRetry != null ? AppButton(label: 'Retry', onPressed: onRetry, variant: AppButtonVariant.ghost) : null,
        );
      case AsyncStatus.error:
        return _Message(
          icon: Icons.error_outline,
          title: errorMessage,
          action: onRetry != null ? AppButton(label: 'Retry', onPressed: onRetry) : null,
        );
      case AsyncStatus.empty:
        return _Message(icon: emptyIcon, title: emptyTitle, message: emptyMessage, action: emptyAction);
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
        child: Semantics(
        label: '$title${message != null ? '. $message' : ''}',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: t.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: t.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, style: t.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ]),
        ),
      ),
    );
  }
}
