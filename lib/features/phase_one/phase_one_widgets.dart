import 'package:flutter/material.dart';

import '../../core/theme/lunora_theme.dart';

class LunoraCard extends StatelessWidget {
  const LunoraCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: LunoraColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LunoraColors.line),
        ),
        child: child,
      );
}

class LunoraButton extends StatelessWidget {
  const LunoraButton({super.key, required this.label, required this.onPressed, this.ghost = false, this.enabled = true});
  final String label;
  final VoidCallback? onPressed;
  final bool ghost;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled ? onPressed : null;
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      backgroundColor: WidgetStatePropertyAll(ghost ? Colors.transparent : LunoraColors.lavenderDeep),
      foregroundColor: WidgetStatePropertyAll(ghost ? LunoraColors.lavenderDeep : Colors.white),
      side: WidgetStatePropertyAll(ghost ? const BorderSide(color: LunoraColors.lavenderDeep) : BorderSide.none),
      textStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w600)),
    );
    return ElevatedButton(onPressed: active, style: style, child: Text(label, textAlign: TextAlign.center));
  }
}

class LunoraPill extends StatelessWidget {
  const LunoraPill({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? LunoraColors.lavenderDeep : LunoraColors.lavender,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label, style: TextStyle(color: selected ? Colors.white : LunoraColors.ink, fontWeight: FontWeight.w500)),
        ),
      );
}

class LunoraProgress extends StatelessWidget {
  const LunoraProgress({super.key, required this.step, required this.total});
  final int step;
  final int total;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Step $step of $total', style: const TextStyle(color: LunoraColors.inkSoft, fontSize: 13)),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: step / total,
              minHeight: 8,
              backgroundColor: LunoraColors.lavender,
              valueColor: const AlwaysStoppedAnimation(LunoraColors.lavenderDeep),
            ),
          ),
        ],
      );
}

String symptomLabel(String id) {
  for (final group in symptomGroups.values) {
    for (final item in group) {
      if (item['id'] == id) return item['label']!;
    }
  }
  return id;
}
