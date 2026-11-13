import 'package:flutter/material.dart';

/// Place above any cycle/ovulation UI.
class NotBirthControlBanner extends StatelessWidget {
  const NotBirthControlBanner({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Warning: not for contraception',
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(
          'Do not use Lunora as contraception. Cycle predictions are estimates.',
          style: Theme.of(context).textTheme.bodySmall,
        )),
      ]),
    ),
  );
}
