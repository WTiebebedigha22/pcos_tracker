#!/usr/bin/env node
/**
 * Lunora UI/UX hardening scaffolder. Frontend only — no backend, no secrets.
 * Idempotent. --dry-run previews, --force overwrites.
 */
const fs = require('fs');
const path = require('path');
const ROOT = process.cwd();
const FORCE = process.argv.includes('--force');
const DRY = process.argv.includes('--dry-run');
let n = { created: 0, skipped: 0, failed: 0 };

function write(rel, body) {
  const full = path.join(ROOT, rel);
  if (fs.existsSync(full) && !FORCE) { console.log(`  ⏭  skip   ${rel}`); n.skipped++; return; }
  if (DRY) { console.log(`  📝 dry    ${rel}`); n.created++; return; }
  try {
    fs.mkdirSync(path.dirname(full), { recursive: true });
    fs.writeFileSync(full, body, 'utf8');
    console.log(`  ✅ create ${rel}`); n.created++;
  } catch (e) { console.error(`  ❌ ${rel}: ${e.message}`); n.failed++; }
}

// ───────────── PHASE 1: Visual foundation ─────────────
console.log('\n🎨 Phase 1 — Visual Foundation');

write('lib/core/theme/design_tokens.dart', `import 'package:flutter/material.dart';

/// Single source of truth. Do not hardcode spacing/radius/duration in widgets.
class DesignTokens {
  static const space = _Space();
  static const radius = _Radius();
  static const elevation = _Elevation();
  static const motion = _Motion();
}

class _Space {
  const _Space();
  final double xxs = 2, xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 48;
}

class _Radius {
  const _Radius();
  final double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, pill = 999;
}

class _Elevation {
  const _Elevation();
  final double none = 0, low = 1, mid = 3, high = 6;
}

class _Motion {
  const _Motion();
  final Duration fast = Duration(milliseconds: 150);
  final Duration base = Duration(milliseconds: 250);
  final Duration slow = Duration(milliseconds: 400);
  final Curve standard = Curves.easeOutCubic;
  final Curve emphasized = Curves.easeInOutCubicEmphasized;
}
`);

write('lib/core/theme/semantic_colors.dart', `import 'package:flutter/material.dart';

/// Health-state colors that are NOT just red/green — PCOS UI needs care.
/// Verify contrast manually; these are starting points, not final.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.insight,
    required this.fertileWindow,
  });

  final Color success, warning, danger, insight, fertileWindow;

  static const light = SemanticColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    danger: Color(0xFFD32F2F),
    insight: Color(0xFF6A1B9A),
    fertileWindow: Color(0xFF90CAF9),
  );

  static const dark = SemanticColors(
    success: Color(0xFF81C784),
    warning: Color(0xFFFFB74D),
    danger: Color(0xFFE57373),
    insight: Color(0xFFCE93D8),
    fertileWindow: Color(0xFF64B5F6),
  );

  @override
  SemanticColors copyWith({
    Color? success, Color? warning, Color? danger,
    Color? insight, Color? fertileWindow,
  }) => SemanticColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    insight: insight ?? this.insight,
    fertileWindow: fertileWindow ?? this.fertileWindow,
  );

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      insight: Color.lerp(insight, other.insight, t)!,
      fertileWindow: Color.lerp(fertileWindow, other.fertileWindow, t)!,
    );
  }
}
`);

write('lib/core/theme/app_theme.dart', `import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'semantic_colors.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light, SemanticColors.light);
  static ThemeData get dark  => _build(Brightness.dark,  SemanticColors.dark);

  static ThemeData _build(Brightness b, SemanticColors semantics) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7C4DFF),
      brightness: b,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: _typeScale(scheme),
      extensions: [semantics],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48), // a11y tap target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radius.md)),
        ),
      ),
      cardTheme: CardTheme(
        elevation: DesignTokens.elevation.low,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radius.lg)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      }),
    );
  }

  static TextTheme _typeScale(ColorScheme s) {
    TextStyle base(double size, FontWeight w) =>
        TextStyle(fontSize: size, fontWeight: w, fontFamily: 'Poppins',
                  color: s.onSurface, height: 1.4);
    return TextTheme(
      displayLarge:  base(57, FontWeight.w400),
      displayMedium: base(45, FontWeight.w400),
      displaySmall:  base(36, FontWeight.w400),
      headlineLarge: base(32, FontWeight.w600),
      headlineMedium:base(28, FontWeight.w600),
      headlineSmall: base(24, FontWeight.w600),
      titleLarge:    base(22, FontWeight.w600),
      titleMedium:   base(16, FontWeight.w600),
      titleSmall:    base(14, FontWeight.w600),
      bodyLarge:     base(16, FontWeight.w400),
      bodyMedium:    base(14, FontWeight.w400),
      bodySmall:     base(12, FontWeight.w400),
      labelLarge:    base(14, FontWeight.w500),
      labelMedium:   base(12, FontWeight.w500),
      labelSmall:    base(11, FontWeight.w500),
    );
  }
}

extension SemanticColorsX on BuildContext {
  SemanticColors get semantics => Theme.of(this).extension<SemanticColors>()!;
}
`);

// Component stubs
write('lib/shared/components/app_button.dart', `import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
            Text(label),
          ]);
    final btn = switch (variant) {
      AppButtonVariant.primary => FilledButton(onPressed: loading ? null : onPressed, child: child),
      AppButtonVariant.secondary => OutlinedButton(onPressed: loading ? null : onPressed, child: child),
      AppButtonVariant.ghost => TextButton(onPressed: loading ? null : onPressed, child: child),
      AppButtonVariant.danger => FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        ).let((s) => FilledButton(style: s, onPressed: loading ? null : onPressed, child: child)),
    };
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

extension _Let<T> on T { R let<R>(R Function(T) f) => f(this); }
`);

write('lib/shared/components/app_card.dart', `import 'package:flutter/material.dart';
import '../../core/theme/design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.padding});
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radius.lg),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(DesignTokens.space.lg),
        child: child,
      ),
    ),
  );
}
`);

write('lib/shared/components/app_chip.dart', `import 'package:flutter/material.dart';

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.selected = false, this.onSelected, this.icon});
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: onSelected,
    avatar: icon != null ? Icon(icon, size: 16) : null,
  );
}
`);

write('lib/shared/components/app_sheet.dart', `import 'package:flutter/material.dart';

class AppSheet {
  static Future<T?> show<T>(BuildContext context, {required Widget child, String? title}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          if (title != null) Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
          child,
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
`);

write('lib/shared/components/confirm_dialog.dart', `import 'package:flutter/material.dart';

class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(cancelLabel)),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: Theme.of(c).colorScheme.error)
                : null,
            onPressed: () => Navigator.pop(c, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return r ?? false;
  }
}
`);

// ───────────── PHASE 2: Universal states & layout ─────────────
console.log('\n🔁 Phase 2 — Universal States & Layout');

write('lib/shared/states/async_state_view.dart', `import 'package:flutter/material.dart';
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
        label: '\$title\${message != null ? \'. \$message\' : \'\'}',
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
`);

write('lib/shared/states/skeletons.dart', `import 'package:flutter/material.dart';

/// Shimmer-free skeleton blocks. Prefer these to spinners on lists/cards.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.width, this.height = 16, this.radius = 8});
  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width, height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: count,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (_, __) => Row(children: const [
      SkeletonBlock(width: 40, height: 40, radius: 20),
      SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SkeletonBlock(width: 160),
        SizedBox(height: 8),
        SkeletonBlock(width: 100, height: 12),
      ])),
    ]),
  );
}
`);

write('lib/shared/states/offline_banner.dart', `import 'package:flutter/material.dart';

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
`);

write('lib/shared/layout/responsive.dart', `import 'package:flutter/material.dart';

enum ScreenSize { compact, medium, expanded }

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;

  static ScreenSize of(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    if (w < 600) return ScreenSize.compact;
    if (w < 1024) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  @override
  Widget build(BuildContext c) {
    switch (of(c)) {
      case ScreenSize.compact: return compact(c);
      case ScreenSize.medium: return (medium ?? compact)(c);
      case ScreenSize.expanded: return (expanded ?? medium ?? compact)(c);
    }
  }
}
`);

// ───────────── PHASE 3: Screens ─────────────
console.log('\n📱 Phase 3 — Screens');

write('lib/features/onboarding/presentation/onboarding_screen.dart', `import 'package:flutter/material.dart';
import '../../../shared/widgets/medical_disclaimer.dart';

/// UX checklist:
/// [ ] 3–4 value-prop pages with skippable progress
/// [ ] Health baseline (birth year, cycle regularity, diagnosis status)
/// [ ] Consent screen (privacy + ToS) — required before continuing
/// [ ] Notification permission with context screen BEFORE OS prompt
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _pages = [
    (Icons.favorite_outline, 'Understand your cycle', 'Built for irregular cycles — not the 28-day myth.'),
    (Icons.insights_outlined, 'See patterns', 'Symptoms, mood, sleep and meds in one place.'),
    (Icons.lock_outline, 'Private by design', 'Your data stays yours. Export or delete anytime.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      Expanded(child: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (_, i) {
          final (icon, title, body) = _pages[i];
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 96),
              const SizedBox(height: 32),
              Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(body, textAlign: TextAlign.center),
            ]),
          );
        },
      )),
      const MedicalDisclaimer(compact: true),
      Padding(padding: const EdgeInsets.all(24), child: Row(children: [
        TextButton(onPressed: () {}, child: const Text('Skip')),
        const Spacer(),
        FilledButton(
          onPressed: () {
            if (_page == _pages.length - 1) { /* TODO: route to baseline */ }
            else { _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut); }
          },
          child: Text(_page == _pages.length - 1 ? 'Continue' : 'Next'),
        ),
      ])),
    ])),
  );
}
`);

write('lib/features/dashboard/presentation/dashboard_screen.dart', `import 'package:flutter/material.dart';
import '../../../shared/states/async_state_view.dart';
import '../../../shared/states/skeletons.dart';
import '../../../shared/components/app_card.dart';
import '../../../shared/widgets/not_birth_control_banner.dart';
import '../../../shared/widgets/medical_disclaimer.dart';

/// UX priority: cycle status > quick-log > recent symptoms > charts.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AsyncStatus _status = AsyncStatus.loading;

  @override
  void initState() {
    super.initState();
    // TODO: replace with real provider listener
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _status = AsyncStatus.data);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lunora')),
    body: AsyncStateView(
      status: _status,
      onRetry: () => setState(() => _status = AsyncStatus.loading),
      builder: (_) => ListView(padding: const EdgeInsets.all(16), children: [
        const NotBirthControlBanner(),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Cycle status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Day 14 · Predicted in ~6 days', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text('Prediction ±3 days', style: Theme.of(context).textTheme.bodySmall),
        ])),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: AppCard(onTap: () {}, child: const _QuickAction(icon: Icons.water_drop_outlined, label: 'Log water'))),
          const SizedBox(width: 12),
          Expanded(child: AppCard(onTap: () {}, child: const _QuickAction(icon: Icons.mood_outlined, label: 'Log mood'))),
        ]),
        const SizedBox(height: 12),
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Recent symptoms', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          const Text('Nothing logged this week. Tap + to add.'),
        ])),
        const MedicalDisclaimer(),
      ]),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 8),
    Text(label, style: Theme.of(context).textTheme.labelLarge),
  ]);
}
`);

write('lib/features/cycle/presentation/cycle_calendar_screen.dart', `import 'package:flutter/material.dart';
import '../../../shared/widgets/not_birth_control_banner.dart';
import '../../../shared/widgets/medical_disclaimer.dart';

/// UX checklist:
/// [ ] "Not birth control" banner at top
/// [ ] Predicted dates rendered as range (± days), not single dot
/// [ ] Past logged cycles visually distinct from predictions
/// [ ] Tap a day → log or view
class CycleCalendarScreen extends StatelessWidget {
  const CycleCalendarScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cycle')),
    body: Column(children: [
      const NotBirthControlBanner(),
      Expanded(child: Center(child: Text('Calendar — replace with table_calendar',
        style: Theme.of(context).textTheme.bodyMedium))),
      const MedicalDisclaimer(compact: true),
    ]),
  );
}
`);

write('lib/features/symptoms/presentation/symptom_logger_screen.dart', `import 'package:flutter/material.dart';
import '../../../shared/components/app_chip.dart';
import '../../../shared/components/app_button.dart';
import '../../../shared/components/app_sheet.dart';

/// UX checklist:
/// [ ] Progressive disclosure — don't show 10 fields at once
/// [ ] Severity via sliders/chips, not text input
/// [ ] Save on dismiss (autosave) OR explicit Save with confirm
class SymptomLoggerScreen extends StatefulWidget {
  const SymptomLoggerScreen({super.key});
  @override
  State<SymptomLoggerScreen> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<SymptomLoggerScreen> {
  final _selected = <String>{};
  static const _symptoms = [
    ('Acne', Icons.face_outlined),
    ('Fatigue', Icons.battery_1_bar),
    ('Hair loss', Icons.content_cut),
    ('Bloating', Icons.circle_outlined),
    ('Anxiety', Icons.psychology_outlined),
    ('Mood swings', Icons.mood_bad_outlined),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Log symptoms')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What are you feeling today?', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: _symptoms.map((s) => AppChip(
          label: s.\$1,
          icon: s.\$2,
          selected: _selected.contains(s.\$1),
          onSelected: (v) => setState(() => v ? _selected.add(s.\$1) : _selected.remove(s.\$1)),
        )).toList()),
        const Spacer(),
        AppButton(
          label: 'Save ( \${_selected.length} )',
          onPressed: _selected.isEmpty ? null : () => AppSheet.show(context,
            title: 'Severity',
            child: const Padding(padding: EdgeInsets.all(16),
              child: Text('Per-symptom severity slider placeholder'))),
          expand: true,
        ),
      ]),
    ),
  );
}
`);

write('lib/features/insights/presentation/insights_screen.dart', `import 'package:flutter/material.dart';
import '../../../shared/widgets/chart_summary.dart';
import '../../../shared/components/app_card.dart';

/// UX checklist:
/// [ ] Every chart has a text summary (accessibility)
/// [ ] Time-range selector (7d / 30d / 90d / all)
/// [ ] Empty state when <7 days of data
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Insights')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mood trend', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const SizedBox(height: 160, child: Center(child: Text('[fl_chart here]'))),
        const ChartSummary(summary: 'Your mood averaged 3.2/5 this month, up from 2.8 last month.'),
      ])),
    ]),
  );
}
`);

write('lib/features/settings/presentation/settings_screen.dart', `import 'package:flutter/material.dart';
import '../../../shared/components/confirm_dialog.dart';

/// UX checklist:
/// [ ] Grouped sections (Account, Preferences, Data, About)
/// [ ] Destructive actions require typed confirmation
/// [ ] Delete account explains what happens
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: ListView(children: [
      const _Header('Account'),
      ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: () {}),
      const _Header('Preferences'),
      const ListTile(leading: Icon(Icons.dark_mode_outlined), title: Text('Theme')),
      const ListTile(leading: Icon(Icons.straighten), title: Text('Units')),
      const _Header('Data'),
      const ListTile(leading: Icon(Icons.download_outlined), title: Text('Export my data')),
      ListTile(
        leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
        title: Text('Delete account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        onTap: () async {
          final ok = await ConfirmDialog.show(context,
            title: 'Delete account?',
            message: 'This permanently removes all cycles, symptoms, and medications. This cannot be undone.',
            confirmLabel: 'Delete', destructive: true);
          // TODO: call delete
        },
      ),
      const _Header('About'),
      const ListTile(leading: Icon(Icons.help_outline), title: Text('Support & resources')),
      const ListTile(leading: Icon(Icons.description_outlined), title: Text('Privacy Policy')),
      const ListTile(leading: Icon(Icons.article_outlined), title: Text('Terms of Service')),
    ]),
  );
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.primary)),
  );
}
`);

write('lib/features/support/presentation/support_screen.dart', `import 'package:flutter/material.dart';

/// PCOS correlates with elevated anxiety/depression. Always offer resources.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Support & resources')),
    body: ListView(padding: const EdgeInsets.all(16), children: const [
      Text('If you are in crisis, contact your local emergency number.'),
      SizedBox(height: 12),
      Text('International directory: findahelpline.com'),
      SizedBox(height: 24),
      Text('PCOS resources:'),
      ListTile(title: Text('PCOS Challenge'), subtitle: Text('pcoschallenge.org')),
      ListTile(title: Text('Verity (UK)'), subtitle: Text('verity-pcos.org.uk')),
    ]),
  );
}
`);

// ───────────── PHASE 4: Accessibility & motion ─────────────
console.log('\n♿ Phase 4 — Accessibility & Motion');

write('lib/shared/a11y/semantics_helpers.dart', `import 'package:flutter/material.dart';

/// Wrap icon-only buttons so screen readers announce intent.
class AccessibleIconButton extends StatelessWidget {
  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    enabled: onPressed != null,
    child: IconButton(
      icon: Icon(icon),
      tooltip: tooltip ?? label,
      onPressed: onPressed,
    ),
  );
}

/// Min 48dp tap target wrapper for custom widgets.
class MinTapTarget extends StatelessWidget {
  const MinTapTarget({super.key, required this.child, this.onTap, this.label});
  final Widget child;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label, button: onTap != null,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      child: InkWell(onTap: onTap, child: Center(child: child)),
    ),
  );
}
`);

write('lib/shared/a11y/reduced_motion.dart', `import 'package:flutter/material.dart';

/// Respects OS "reduce motion" — use for non-essential transitions.
class ReducedMotion {
  static bool enabled(BuildContext c) =>
      MediaQuery.maybeOf(c)?.disableAnimations ?? false;

  static Duration duration(BuildContext c, Duration normal) =>
      enabled(c) ? Duration.zero : normal;
}
`);

write('lib/shared/a11y/dynamic_text_scope.dart', `import 'package:flutter/material.dart';

/// Wrap large screens in this to cap text scale so layout doesn't break
/// (still respects user preference up to a point).
class DynamicTextScope extends StatelessWidget {
  const DynamicTextScope({super.key, required this.child, this.max = 1.6});
  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(textScaler: TextScaler.linear(mq.textScaler.scale(1).clamp(1.0, max))),
      child: child,
    );
  }
}
`);

write('test/widget/tap_target_audit.dart', `import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pump a screen and call this to assert every tappable ≥48dp.
/// Usage: await expectMinTapTargets(tester);
Future<void> expectMinTapTargets(WidgetTester tester) async {
  final tappables = find.byWidgetPredicate((w) =>
      w is InkWell || w is IconButton || w is FilledButton || w is TextButton || w is OutlinedButton);
  for (final el in tappables.evaluate()) {
    final box = el.renderObject as RenderBox?;
    if (box == null || !box.hasSize) continue;
    final size = box.size;
    expect(size.width >= 47.0 && size.height >= 47.0, isTrue,
      reason: 'Tappable below 48dp: \${el.widget.runtimeType} \${size.width}x\${size.height}');
  }
}
`);

// ───────────── PHASE 5: Interaction polish ─────────────
console.log('\n✨ Phase 5 — Interaction Polish');

write('lib/shared/feedback/haptics.dart', `import 'package:flutter/services.dart';

class Haptics {
  static Future<void> light() => HapticFeedback.lightImpact();
  static Future<void> medium() => HapticFeedback.mediumImpact();
  static Future<void> success() => HapticFeedback.mediumImpact();
  static Future<void> error() => HapticFeedback.heavyImpact();
}
`);

write('lib/shared/feedback/toast.dart', `import 'package:flutter/material.dart';

class Toast {
  static void show(BuildContext c, String message, {SnackBarAction? action, bool error = false}) {
    ScaffoldMessenger.of(c)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(c).colorScheme.error : null,
        action: action,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ));
  }

  static void undo(BuildContext c, String message, VoidCallback onUndo) =>
      show(c, message, action: SnackBarAction(label: 'Undo', onPressed: onUndo));
}
`);

write('lib/shared/forms/validators.dart', `/// Inline, on-blur validators. Never validate on every keystroke.
class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    return RegExp(r'^[^@]+@[^@]+\\.[^@]+\$').hasMatch(v) ? null : 'Invalid email';
  }
  static String? minLength(int n) => (v) =>
      (v == null || v.length < n) ? 'At least \$n characters' : null;
}
`);

write('docs/STYLEGUIDE.md', `# Lunora Style Guide

## Spacing
Use \`DesignTokens.space\` — never hardcode. Scale: 2 / 4 / 8 / 12 / 16 / 24 / 32 / 48.

## Radius
4 / 8 / 12 / 16 / 24 / pill.

## Motion
- fast 150ms — micro feedback
- base 250ms — page/state transitions
- slow 400ms — reveals
- Respect \`ReducedMotion.enabled(context)\`

## Color
- Semantic layer (\`SemanticColors\`) for health states — not raw Material colors
- Verify contrast ≥4.5:1 for body, ≥3:1 for large text
- The "soft pink" palette is a known accessibility risk; test both themes

## Typography
Poppins. Scale from \`AppTheme._typeScale\`. Do not override \`fontSize\` inline.

## Components
- Buttons: \`AppButton\` (variants: primary, secondary, ghost, danger)
- Cards: \`AppCard\`
- Chips: \`AppChip\`
- Sheets: \`AppSheet.show()\`
- Confirmation: \`ConfirmDialog.show()\` (destructive requires this)
- Toast: \`Toast.show()\` / \`Toast.undo()\`

## Screen checklist (every screen)
- [ ] Handles loading / empty / error / offline
- [ ] Loading uses skeleton for lists, spinner only for actions
- [ ] Empty state has icon + title + optional CTA
- [ ] Icon-only buttons wrapped in \`AccessibleIconButton\`
- [ ] Interactive widgets ≥48dp
- [ ] Respects textScaler (no fixed-height text rows)
- [ ] Charts include \`ChartSummary\`
- [ ] Destructive actions go through \`ConfirmDialog\`
- [ ] Prediction/dosage screens include \`MedicalDisclaimer\`
`);

console.log('\n────────────────────────────────────────');
console.log(`✅ created ${n.created}  ⏭ skipped ${n.skipped}  ❌ failed ${n.failed}`);
if (DRY) console.log('(dry run)');
console.log(`
Manual follow-ups (design/device work, no script can do):
  1. WCAG contrast check on real palette in BOTH themes.
  2. Swap stubs into your existing screens — the scaffolder creates
     *new* files; you must wire them into your router/riverpod providers.
  3. Replace [fl_chart here] with real charts + wire ChartSummary.
  4. Test onboarding on a real device with large text scale (2.0x).
  5. Screen-reader pass: TalkBack + VoiceOver on Dashboard + Logger.
  6. Verify tap targets via test/widget/tap_target_audit.dart.
  7. Design review of the Dashboard priority — "am I late?" should be
     above the fold on the smallest supported screen.
  8. Decide skip/save semantics on the symptom logger (autosave vs explicit).
`);