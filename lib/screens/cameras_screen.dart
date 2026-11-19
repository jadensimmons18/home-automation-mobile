import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/home_state.dart';
import '../state/models.dart';
import '../state/nav_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';
import 'shell.dart';

enum _Filter { all, outside, inside }

class CamerasScreen extends StatefulWidget {
  const CamerasScreen({super.key});

  @override
  State<CamerasScreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends State<CamerasScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();
    final featured = home.featuredCamera;
    final tiles = home.cameras.where((c) {
      if (c.id == featured.id) return false;
      return switch (_filter) {
        _Filter.all => true,
        _Filter.outside => c.zone == CameraZone.outside,
        _Filter.inside => c.zone == CameraZone.inside,
      };
    }).toList();

    return AmbientBackground(
      blobs: const [
        Blob(top: -160, right: -120, width: 420, height: 420, color: Color(0xFF969EB0), opacity: 0.40),
        Blob(bottom: -140, left: -140, width: 440, height: 400, color: Color(0xFF7C8292), opacity: 0.34),
      ],
      child: ScreenScroll(
        bottomInset: Shell.contentBottomInset(context),
        children: [
          ScreenHeader(
            title: 'Cameras',
            onBack: () => context.read<NavState>().go(AppTab.home),
            actionIcon: AppIcon.grid,
            actionLabel: 'Layout',
            onAction: () => comingSoon(context, 'Camera layouts'),
          ),
          _FeaturedFeed(camera: featured, frontLocked: home.isLocked('front')),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                for (final (label, filter) in [('All', _Filter.all), ('Outside', _Filter.outside), ('Inside', _Filter.inside)]) ...[
                  Pill(
                    label: label,
                    height: 36,
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
                  const SizedBox(width: 8),
                ],
                Pill(label: 'Recordings', height: 36, onTap: () => comingSoon(context, 'Recordings')),
              ],
            ),
          ),
          if (tiles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('No other cameras here', textAlign: TextAlign.center, style: txt(13, color: AppColors.muted)),
            )
          else
            _CameraGrid(
              cameras: tiles,
              onTap: (cam) {
                if (cam.privacy) {
                  showToast(context, '${cam.name} is in privacy mode');
                } else {
                  home.featureCamera(cam.id);
                }
              },
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionLabel(
                'Today',
                trailing: Tap(
                  semanticLabel: 'See all events',
                  onTap: () => comingSoon(context, 'Event history'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('See all', style: txt(13, color: AppColors.accent)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Glass(
                radius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  children: [
                    for (final (i, e) in home.events.indexed) ...[
                      if (i > 0) const RowDivider(),
                      _EventRow(
                        event: e,
                        unread: !home.readEventIds.contains(e.id),
                        onTap: () => home.markEventRead(e.id),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedFeed extends StatelessWidget {
  const _FeaturedFeed({required this.camera, required this.frontLocked});

  final CameraFeed camera;
  final bool frontLocked;

  @override
  Widget build(BuildContext context) {
    final home = context.read<HomeState>();
    final isFront = camera.id == 'front';
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorder),
        gradient: LinearGradient(
          begin: const Alignment(-0.25, -1),
          end: const Alignment(0.25, 1),
          colors: camera.gradient.length == 3
              ? camera.gradient
              : [camera.gradient.first.withValues(alpha: 1), camera.gradient.last],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0x73000000)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Row(
              children: [
                Glass(
                  height: 26,
                  radius: 13,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Dot(color: AppColors.live, size: 6),
                      const SizedBox(width: 6),
                      Text('LIVE', style: txt(11, weight: FontWeight.w600, tracking: 0.06)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(camera.name, style: txt(12, color: const Color(0xD9F2F3F5))),
              ],
            ),
          ),
          const Positioned(top: 18, right: 16, child: _LiveClock()),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Glass(
              height: 52,
              radius: 26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FeedButton(icon: AppIcon.mic, label: 'Talk', onTap: () => comingSoon(context, 'Two-way talk')),
                  _FeedButton(icon: AppIcon.camera, label: 'Snapshot', onTap: () => comingSoon(context, 'Snapshots')),
                  _FeedButton(
                    icon: frontLocked ? AppIcon.lock : AppIcon.unlock,
                    label: frontLocked ? 'Unlock front door' : 'Lock front door',
                    onTap: () {
                      home.toggleLock('front');
                      showToast(context, frontLocked ? 'Front door unlocked' : 'Front door locked');
                    },
                    enabled: isFront,
                  ),
                  _FeedButton(icon: AppIcon.fullscreen, label: 'Full screen', onTap: () => comingSoon(context, 'Full screen')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedButton extends StatelessWidget {
  const _FeedButton({required this.icon, required this.label, required this.onTap, this.enabled = true});

  final AppIcon icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tap(
      semanticLabel: label,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AppIconView(icon, color: enabled ? AppColors.text : const Color(0x4DF2F3F5)),
        ),
      ),
    );
  }
}

class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _now = DateTime.now()));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    String two(int v) => v.toString().padLeft(2, '0');
    final label = '$h:${two(_now.minute)}:${two(_now.second)} ${_now.hour < 12 ? 'AM' : 'PM'}';
    return Text(label, style: txt(12, color: const Color(0xBFF2F3F5), features: tabularFigures));
  }
}

class _CameraGrid extends StatelessWidget {
  const _CameraGrid({required this.cameras, required this.onTap});

  final List<CameraFeed> cameras;
  final ValueChanged<CameraFeed> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < cameras.length; r += 2) ...[
          if (r > 0) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _tile(cameras[r])),
              const SizedBox(width: 10),
              Expanded(child: r + 1 < cameras.length ? _tile(cameras[r + 1]) : const SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _tile(CameraFeed cam) {
    if (cam.privacy) {
      return Tap(
        semanticLabel: '${cam.name}, privacy mode',
        onTap: () => onTap(cam),
        child: Glass(
          height: 100,
          radius: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppIconView(AppIcon.videoOff, color: AppColors.muted),
              const SizedBox(height: 6),
              Text('${cam.name} · Privacy', style: txt(12, color: AppColors.muted)),
            ],
          ),
        ),
      );
    }
    return Tap(
      semanticLabel: 'Show ${cam.name}',
      onTap: () => onTap(cam),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          gradient: LinearGradient(
            begin: const Alignment(-0.35, -1),
            end: const Alignment(0.35, 1),
            colors: [cam.gradient.first, cam.gradient.last],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(top: 10, left: 10, child: Dot(color: AppColors.live, size: 6)),
            Positioned(left: 12, bottom: 10, child: Text(cam.name, style: txt(12))),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.unread, required this.onTap});

  final CameraEvent event;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tap(
      semanticLabel: event.title,
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: LinearGradient(
                  begin: const Alignment(-0.35, -1),
                  end: const Alignment(0.35, 1),
                  colors: event.gradient,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: txt(14)),
                  const SizedBox(height: 2),
                  Text('${event.cameraName} · ${event.time}', style: txt(12, color: AppColors.muted)),
                ],
              ),
            ),
            if (unread) const Dot(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
