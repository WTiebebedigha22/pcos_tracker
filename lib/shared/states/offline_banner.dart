import 'package:flutter/material.dart';

/// Show at top of scaffold body when connectivity is lost.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: 'Offline. Changes will sync later.',
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Row(children: [
        Icon(Icons.cloud_off, size: 16, color: Theme.of(context).colorScheme.onTertiaryContainer),
        const SizedBox(width: 8),
        Expanded(child: Text('Offline — changes sync later',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onTertiaryContainer))),
      ]),
    ),
  );
}
