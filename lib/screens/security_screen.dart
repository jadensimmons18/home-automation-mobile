import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/home_state.dart';
import '../state/models.dart';
import '../state/nav_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';
import 'shell.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();
    final nav = context.read<NavState>();
    final (title, subtitle) = switch (home.armMode) {
      ArmMode.off => ('Disarmed', 'Sensors are watching but won’t alert'),
      ArmMode.home => ('Armed · Home', 'Perimeter sensors on, motion off'),
      ArmMode.away => ('Armed · Away', 'All sensors and cameras alerting'),
    };

    return AmbientBackground(
      blobs: const [
        Blob(top: -120, left: -100, width: 440, height: 420, color: Color(0xFF8CA098), opacity: 0.30, stop: 0.66),
        Blob(bottom: -140, right: -140, width: 420, height: 400, color: Color(0xFF8C92A0), opacity: 0.32),
      ],
      child: ScreenScroll(
        bottomInset: Shell.contentBottomInset(context),
        children: [
          ScreenHeader(
            title: 'Security',
            onBack: () => nav.go(AppTab.home),
            actionIcon: AppIcon.video,
            actionLabel: 'Cameras',
            onAction: () => nav.go(AppTab.cameras),
          ),

          // ---- Alarm status ----
          Glass(
            radius: 28,
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0x0FFFFFFF),
                    border: Border.all(color: const Color(0x1FFFFFFF)),
                  ),
                  child: Center(
                    child: AppIconView(
                      AppIcon.shieldCheck,
                      size: 34,
                      strokeWidth: 1.5,
                      color: home.isArmed ? AppColors.good : AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title, style: txt(22, weight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle, textAlign: TextAlign.center, style: txt(13, color: AppColors.muted)),
                const SizedBox(height: 16),
                Segmented<ArmMode>(
                  height: 40,
                  options: const [
                    (ArmMode.off, 'Disarmed'),
                    (ArmMode.home, 'Home'),
                    (ArmMode.away, 'Away'),
                  ],
                  value: home.armMode,
                  onChanged: home.setArmMode,
                ),
              ],
            ),
          ),

          // ---- Locks ----
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Locks'),
              const SizedBox(height: 8),
              Glass(
                radius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    for (final (i, lock) in home.locks.indexed) ...[
                      if (i > 0) const RowDivider(),
                      SizedBox(
                        height: 62,
                        child: Row(
                          children: [
                            AppIconView(lock.locked ? AppIcon.lock : AppIcon.unlock, color: AppColors.text),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(lock.name, style: txt(15)),
                                  const SizedBox(height: 2),
                                  Text(lock.locked ? lock.lockedDetail : 'Unlocked',
                                      style: txt(12, color: lock.locked ? AppColors.muted : AppColors.warn)),
                                ],
                              ),
                            ),
                            PillSwitch(
                              value: lock.locked,
                              label: '${lock.name} lock',
                              onChanged: (_) => home.toggleLock(lock.id),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ---- Sensors / who's home ----
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sensors', style: txt(12, color: AppColors.muted)),
                        const SizedBox(height: 10),
                        Text('${home.windowsClosed} windows closed', style: txt(15)),
                        const SizedBox(height: 10),
                        Text('Smoke & CO normal', style: txt(12, color: AppColors.good)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Who’s home', style: txt(12, color: AppColors.muted)),
                        const SizedBox(height: 10),
                        _Avatars(initials: home.peopleHome, extra: home.peopleAway),
                        const SizedBox(height: 10),
                        Text('${home.peopleHome.length} home · ${home.peopleAway} away',
                            style: txt(12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatars extends StatelessWidget {
  const _Avatars({required this.initials, required this.extra});

  final List<String> initials;
  final int extra;

  static const _colors = [Color(0xFFB9C3D3), Color(0xFF8A93A3)];

  @override
  Widget build(BuildContext context) {
    final avatars = <Widget>[
      for (final (i, letter) in initials.indexed)
        _circle(
          color: _colors[i % _colors.length],
          child: Text(letter, style: txt(12, weight: FontWeight.w600, color: AppColors.background)),
        ),
      if (extra > 0)
        _circle(
          color: const Color(0xFF26272B),
          child: Text('+$extra', style: txt(12, color: AppColors.muted)),
        ),
    ];
    return SizedBox(
      height: 30,
      child: Stack(
        children: [
          for (final (i, a) in avatars.indexed) Positioned(left: i * 22.0, child: a),
        ],
      ),
    );
  }

  Widget _circle({required Color color, required Widget child}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF1A1B1F), width: 2),
      ),
      child: Center(child: child),
    );
  }
}
