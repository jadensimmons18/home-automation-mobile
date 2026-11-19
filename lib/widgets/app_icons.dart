import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Stroke icons copied from the design's inline SVGs (24×24 viewBox).
enum AppIcon {
  bell('<path d="M6 16V11a6 6 0 1112 0v5l1.5 2h-15z"/><path d="M10 20a2 2 0 004 0"/>'),
  mic('<rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0014 0M12 18v3"/>'),
  video('<path d="M15 10l5-3v10l-5-3"/><rect x="3" y="6" width="12" height="12" rx="3"/>'),
  videoOff('<path d="M15 10l5-3v10l-5-3"/><rect x="3" y="6" width="12" height="12" rx="3"/><path d="M3 3l18 18"/>'),
  thermometer('<path d="M14 14.8V5a2 2 0 10-4 0v9.8a4 4 0 104 0z"/>'),
  shield('<path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3z"/>'),
  shieldCheck('<path d="M12 3l7 3v6c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6l7-3z"/><path d="M9 12l2 2 4-4"/>'),
  bulb('<path d="M9 18h6M10 21h4M12 3a6 6 0 00-3.5 10.9c.6.4 1 1.1 1 1.9V16h5v-.2c0-.8.4-1.5 1-1.9A6 6 0 0012 3z"/>'),
  bolt('<path d="M13 3L5 13h6l-1 8 8-10h-6l1-8z"/>'),
  home('<path d="M4 11l8-7 8 7v8a1 1 0 01-1 1h-4v-6h-6v6H5a1 1 0 01-1-1z"/>'),
  back('<path d="M15 5l-7 7 7 7"/>'),
  clock('<circle cx="12" cy="12" r="8"/><path d="M12 8v4l3 2"/>'),
  check('<path d="M5 12l5 5 9-10"/>'),
  grid('<rect x="4" y="4" width="7" height="7" rx="2"/><rect x="13" y="4" width="7" height="7" rx="2"/><rect x="4" y="13" width="7" height="7" rx="2"/><rect x="13" y="13" width="7" height="7" rx="2"/>'),
  camera('<path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/>'),
  lock('<rect x="5" y="11" width="14" height="10" rx="2.5"/><path d="M8 11V8a4 4 0 018 0v3"/>'),
  unlock('<rect x="5" y="11" width="14" height="10" rx="2.5"/><path d="M8 11V8a4 4 0 017.5-2"/>'),
  fullscreen('<path d="M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"/>'),
  calendar('<rect x="4" y="5" width="16" height="15" rx="3"/><path d="M4 10h16M9 3v4M15 3v4"/>'),
  minus('<path d="M6 12h12"/>'),
  plus('<path d="M6 12h12M12 6v12"/>'),
  moon('<path d="M20 14.5A8 8 0 019.5 4 8 8 0 1020 14.5z"/>'),
  sliders('<path d="M4 7h10M18 7h2M4 17h4M12 17h8"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="17" r="2"/>'),
  send('<path d="M12 19V5M6 11l6-6 6 6"/>');

  const AppIcon(this.body);
  final String body;
}

class AppIconView extends StatelessWidget {
  const AppIconView(
    this.icon, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 1.6,
  });

  final AppIcon icon;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? Colors.white;
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" '
        'stroke="#000" stroke-width="$strokeWidth" stroke-linecap="round" stroke-linejoin="round">'
        '${icon.body}</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
    );
  }
}
