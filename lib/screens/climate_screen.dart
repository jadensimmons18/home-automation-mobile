import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/home_state.dart';
import '../state/models.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';

Route<void> climateRoute() => PageRouteBuilder(
      pageBuilder: (_, _, _) => const ClimateScreen(),
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

class ClimateScreen extends StatelessWidget {
  const ClimateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();
    return Scaffold(
      body: AmbientBackground(
        blobs: const [
          Blob(top: 80, centerX: true, width: 440, height: 420, color: Color(0xFF969EB0), opacity: 0.34, stop: 0.66),
          Blob(bottom: -160, left: -120, width: 400, height: 380, color: Color(0xFFA59E96), opacity: 0.20),
        ],
        child: ScreenScroll(
          gap: 18,
          bottomInset: MediaQuery.paddingOf(context).bottom + 32,
          children: [
            ScreenHeader(
              title: 'Climate',
              onBack: () => Navigator.of(context).pop(),
              actionIcon: AppIcon.calendar,
              actionLabel: 'Schedule',
              onAction: () => comingSoon(context, 'Climate schedule'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Center(child: _Dial(home: home)),
            ),
            Transform.translate(
              offset: const Offset(0, -4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassIconButton(
                    icon: AppIcon.minus,
                    label: 'Lower temperature',
                    size: 56,
                    iconSize: 22,
                    onTap: () => home.setTargetTemp(home.targetTemp - 1),
                  ),
                  const SizedBox(width: 18),
                  GlassIconButton(
                    icon: AppIcon.plus,
                    label: 'Raise temperature',
                    size: 56,
                    iconSize: 22,
                    onTap: () => home.setTargetTemp(home.targetTemp + 1),
                  ),
                ],
              ),
            ),
            Segmented<ClimateMode>(
              glass: true,
              options: const [
                (ClimateMode.cool, 'Cool'),
                (ClimateMode.heat, 'Heat'),
                (ClimateMode.auto, 'Auto'),
                (ClimateMode.off, 'Off'),
              ],
              value: home.climateMode,
              onChanged: home.setClimateMode,
            ),
            Glass(
              radius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (final (i, room) in home.rooms.indexed) ...[
                    if (i > 0) const RowDivider(),
                    SizedBox(
                      height: 54,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(room.name, style: txt(15)),
                          Text('${room.temp}° · ${room.humidity}%',
                              style: txt(15, color: AppColors.soft, features: tabularFigures)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Glass(
              radius: 24,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  const AppIconView(AppIcon.moon, color: AppColors.text),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bedtime at ${home.bedtimeTime}', style: txt(14)),
                        const SizedBox(height: 2),
                        Text('Cools to ${home.bedtimeTarget}° · Atlas learned this',
                            style: txt(12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  PillSwitch(
                    value: home.bedtimeEnabled,
                    onChanged: (_) => home.toggleBedtime(),
                    width: 36,
                    height: 22,
                    label: 'Bedtime schedule',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({required this.home});

  final HomeState home;

  @override
  Widget build(BuildContext context) {
    final fraction = (home.targetTemp - HomeState.minTarget) / (HomeState.maxTarget - HomeState.minTarget);
    final off = home.climateMode == ClimateMode.off;
    return Semantics(
      label: '${home.climateModeLabel.toLowerCase()} ${home.targetTemp} degrees',
      child: SizedBox(
        width: 260,
        height: 260,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: fraction),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          builder: (context, value, child) => CustomPaint(
            painter: _ArcPainter(fraction: value, color: off ? AppColors.muted : AppColors.accent),
            child: child,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Glass(
              shape: BoxShape.circle,
              fill: const Color(0xB816171B),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(home.climateModeLabel,
                        style: txt(12, color: off ? AppColors.muted : AppColors.accent, tracking: 0.12)),
                    const SizedBox(height: 4),
                    Text('${home.targetTemp}°',
                        style: txt(72, weight: FontWeight.w200, tracking: -0.05, height: 1)),
                    const SizedBox(height: 4),
                    Text('Inside now ${home.insideTemp}° · ${home.humidity}% humidity',
                        style: txt(13, color: AppColors.muted)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 270° arc starting at the lower left, filled clockwise up to [fraction].
class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  static const _start = 135 * math.pi / 180;
  static const _sweep = 270 * math.pi / 180;
  static const _thickness = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _thickness / 2,
      _thickness / 2,
      size.width - _thickness,
      size.height - _thickness,
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thickness
      ..color = const Color(0x1AFFFFFF);
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _thickness
      ..color = color;
    canvas.drawArc(rect, _start, _sweep, false, track);
    if (fraction > 0) canvas.drawArc(rect, _start, _sweep * fraction, false, fill);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.fraction != fraction || old.color != color;
}
