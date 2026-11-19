import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/home_state.dart';
import '../state/models.dart';
import '../state/nav_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';
import 'climate_screen.dart';
import 'shell.dart';

const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();
    final nav = context.read<NavState>();
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return AmbientBackground(
      blobs: const [
        Blob(top: -140, left: -120, width: 420, height: 420, color: Color(0xFF969EB0), opacity: 0.42),
        Blob(top: 300, right: -170, width: 400, height: 400, color: Color(0xFF788092), opacity: 0.38),
        Blob(bottom: -160, left: -60, width: 420, height: 380, color: Color(0xFFAAA298), opacity: 0.22),
      ],
      child: ScreenScroll(
        gap: 14,
        bottomInset: Shell.contentBottomInset(context),
        children: [
          // ---- Greeting ----
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_weekdays[now.weekday - 1]}, ${_months[now.month - 1]} ${now.day}',
                          style: txt(13, color: AppColors.muted, tracking: 0.02)),
                      const SizedBox(height: 6),
                      Text('$greeting, ${home.userName}',
                          style: txt(28, weight: FontWeight.w500, tracking: -0.02)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Dot(color: home.allSecure ? AppColors.good : AppColors.warn, glow: true),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${home.securitySummary} · ${home.insideTemp}° inside · ${home.outsideTemp}° out',
                              style: txt(13, color: AppColors.soft),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GlassIconButton(
                  icon: AppIcon.bell,
                  label: 'Notifications',
                  badgeColor: AppColors.accent,
                  onTap: () => comingSoon(context, 'Notifications'),
                ),
              ],
            ),
          ),

          // ---- Ask Atlas ----
          Tap(
            semanticLabel: 'Ask Atlas',
            onTap: () => nav.go(AppTab.atlas),
            child: Glass(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const AtlasOrb(size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ask Atlas', style: txt(16, weight: FontWeight.w500)),
                        const SizedBox(height: 3),
                        Text('“Dim the living room and lock up”',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: txt(13, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Color(0x1AFFFFFF), shape: BoxShape.circle),
                    child: const Center(child: AppIconView(AppIcon.mic, size: 18, color: AppColors.text)),
                  ),
                ],
              ),
            ),
          ),

          // ---- Cameras ----
          Tap(
            semanticLabel: 'Cameras',
            onTap: () => nav.go(AppTab.cameras),
            child: Glass(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const AppIconView(AppIcon.video, color: AppColors.text),
                      const SizedBox(width: 10),
                      Text('Cameras', style: txt(16, weight: FontWeight.w500)),
                      const Spacer(),
                      Text(
                        '${home.liveCameraCount} live'
                        '${home.newEventCount > 0 ? ' · ${home.newEventCount} new ${home.newEventCount == 1 ? 'event' : 'events'}' : ''}',
                        style: txt(12, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final (i, cam) in home.cameras.where((c) => !c.privacy).take(3).indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: _CameraThumb(camera: cam)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ---- Tiles ----
          _TileGrid(
            children: [
              _Tile(
                semanticLabel: 'Climate',
                onTap: () => Navigator.of(context).push(climateRoute()),
                icon: AppIcon.thermometer,
                badge: Text(home.climateModeShort,
                    style: txt(12, color: home.climateMode == ClimateMode.off ? AppColors.muted : AppColors.accent)),
                value: Text('${home.insideTemp}°', style: txt(30, weight: FontWeight.w300, tracking: -0.03)),
                caption: home.climateMode == ClimateMode.off ? 'Climate · off' : 'Climate · to ${home.targetTemp}°',
              ),
              _Tile(
                semanticLabel: 'Security',
                onTap: () => nav.go(AppTab.security),
                icon: AppIcon.shieldCheck,
                badge: Text(home.isArmed ? 'Armed' : 'Disarmed',
                    style: txt(12, color: home.isArmed ? AppColors.good : AppColors.muted)),
                value: Text(
                  switch (home.armMode) {
                    ArmMode.home => 'Home mode',
                    ArmMode.away => 'Away mode',
                    ArmMode.off => 'Disarmed',
                  },
                  style: txt(20, weight: FontWeight.w500, tracking: -0.01),
                ),
                caption: 'Security · ${home.lockedCount} locked',
              ),
              _Tile(
                semanticLabel: home.lightsOn ? 'Lights on. Turn off' : 'Lights off. Turn on',
                onTap: home.toggleLights,
                icon: AppIcon.bulb,
                badge: PillSwitch(
                  value: home.lightsOn,
                  onChanged: (_) => home.toggleLights(),
                  width: 36,
                  height: 22,
                  label: 'Lights',
                  expandTouchTarget: false,
                ),
                value: Text(home.lightsOn ? '${home.lightsOnCount} on' : 'Off',
                    style: txt(30, weight: FontWeight.w300, tracking: -0.03)),
                caption: home.lightsOn ? 'Lights · ${home.lightRooms} rooms' : 'Lights · all off',
              ),
              _Tile(
                semanticLabel: 'Energy',
                onTap: () => nav.go(AppTab.energy),
                icon: AppIcon.bolt,
                badge: const _MiniBars(),
                value: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: home.energy[EnergyRange.day]!.total),
                    TextSpan(text: ' kWh', style: txt(14, color: AppColors.muted)),
                  ]),
                  style: txt(30, weight: FontWeight.w300, tracking: -0.03),
                ),
                caption: 'Energy · today',
              ),
            ],
          ),

          // ---- Scenes ----
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel('Scenes'),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: [
                      for (final (i, scene) in home.scenes.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Pill(
                          label: scene,
                          selected: scene == home.activeScene,
                          onTap: () => home.setScene(scene),
                        ),
                      ],
                    ],
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

class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < children.length; r += 2) ...[
          if (r > 0) const SizedBox(height: 12),
          SizedBox(
            height: 116,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[r]),
                const SizedBox(width: 12),
                Expanded(child: r + 1 < children.length ? children[r + 1] : const SizedBox()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CameraThumb extends StatelessWidget {
  const _CameraThumb({required this.camera});

  final CameraFeed camera;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: const Alignment(-0.35, -1),
          end: const Alignment(0.35, 1),
          colors: [camera.gradient.first, camera.gradient.last],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(top: 7, left: 8, child: Dot(color: AppColors.live, size: 6)),
          Positioned(
            left: 8,
            bottom: 7,
            right: 4,
            child: Text(camera.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: txt(11, color: const Color(0xD9F2F3F5))),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.semanticLabel,
    required this.onTap,
    required this.icon,
    required this.badge,
    required this.value,
    required this.caption,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final AppIcon icon;
  final Widget badge;
  final Widget value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Tap(
      semanticLabel: semanticLabel,
      onTap: onTap,
      child: Glass(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 22,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIconView(icon, color: AppColors.text),
                  badge,
                ],
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DefaultTextStyle.merge(style: const TextStyle(height: 1.15), child: value),
                      const SizedBox(height: 2),
                      Text(caption, maxLines: 1, style: txt(13, color: AppColors.muted)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBars extends StatelessWidget {
  const _MiniBars();

  @override
  Widget build(BuildContext context) {
    const heights = [8.0, 14.0, 11.0, 20.0, 16.0];
    return SizedBox(
      height: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, h) in heights.indexed) ...[
            if (i > 0) const SizedBox(width: 3),
            Container(
              width: 4,
              height: h,
              decoration: BoxDecoration(
                color: i == heights.length - 1 ? AppColors.accent : const Color(0x4DF2F3F5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
