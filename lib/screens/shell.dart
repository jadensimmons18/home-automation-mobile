import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/nav_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';
import 'atlas_screen.dart';
import 'cameras_screen.dart';
import 'energy_screen.dart';
import 'home_screen.dart';
import 'security_screen.dart';

/// Holds the five tab screens and the floating glass navigation bar.
class Shell extends StatelessWidget {
  const Shell({super.key});

  static const navHeight = 66.0;
  static const navBottom = 26.0;

  /// Space a tab screen should leave at the bottom so content clears the nav.
  static double contentBottomInset(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + navBottom + navHeight + 24;

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavState>();
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return PopScope(
      canPop: nav.tab == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) nav.go(AppTab.home);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: nav.tab.index,
                children: const [
                  HomeScreen(),
                  CamerasScreen(),
                  AtlasScreen(),
                  SecurityScreen(),
                  EnergyScreen(),
                ],
              ),
            ),
            if (!keyboardOpen)
              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.paddingOf(context).bottom + navBottom,
                child: _NavBar(current: nav.tab, onSelect: nav.go),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.current, required this.onSelect});

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Main',
      child: Glass(
        height: Shell.navHeight,
        radius: Shell.navHeight / 2,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(AppTab.home, 'Home', const _NavIcon(AppIcon.home)),
            _item(AppTab.cameras, 'Cameras', const _NavIcon(AppIcon.video)),
            _item(AppTab.atlas, 'Atlas', const AtlasOrb(size: 26, glow: 14, glowOpacity: 0.5)),
            _item(AppTab.security, 'Security', const _NavIcon(AppIcon.shield)),
            _item(AppTab.energy, 'Energy', const _NavIcon(AppIcon.bolt)),
          ],
        ),
      ),
    );
  }

  Widget _item(AppTab tab, String label, Widget icon) {
    final selected = tab == current;
    return Semantics(
      selected: selected,
      child: Tap(
        semanticLabel: label,
        onTap: () => onSelect(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? const Color(0x1FFFFFFF) : Colors.transparent,
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: selected ? AppColors.text : AppColors.muted),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon);

  final AppIcon icon;

  @override
  Widget build(BuildContext context) => AppIconView(icon, size: 22);
}
