import 'dart:async';
import 'dart:ui';

import 'package:material_ui/material_ui.dart';

import '../theme.dart';
import 'app_icons.dart';

/// Frosted-glass surface used for every card, button and bar in the design.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 26,
    this.padding = EdgeInsets.zero,
    this.fill = AppColors.glassFill,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color fill;
  final double? width;
  final double? height;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;
    final borderRadius = isCircle ? null : BorderRadius.circular(radius);
    final clipped = isCircle
        ? ClipOval(child: _blurred(null))
        : ClipRRect(borderRadius: borderRadius!, child: _blurred(borderRadius));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: borderRadius,
        boxShadow: const [
          BoxShadow(color: Color(0x47000000), blurRadius: 32, offset: Offset(0, 12)),
        ],
      ),
      child: clipped,
    );
  }

  Widget _blurred(BorderRadius? borderRadius) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: borderRadius,
          border: Border.all(color: AppColors.glassBorder),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: const Alignment(0, -0.6),
            colors: [Colors.white.withValues(alpha: 0.05), fill],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Makes any child tappable without a Material ripple.
class Tap extends StatelessWidget {
  const Tap({super.key, required this.child, this.onTap, this.semanticLabel});

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// Round glass icon button (44px), as in each screen's header.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 44,
    this.iconSize = 20,
    this.badgeColor,
  });

  final AppIcon icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      semanticLabel: label,
      child: Stack(
        children: [
          Glass(
            shape: BoxShape.circle,
            width: size,
            height: size,
            child: Center(child: AppIconView(icon, size: iconSize, color: AppColors.text)),
          ),
          if (badgeColor != null)
            Positioned(
              top: 11,
              right: 12,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}

/// Header row: back button, centered title, action button.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
    required this.actionIcon,
    required this.actionLabel,
    this.onAction,
  });

  final String title;
  final VoidCallback onBack;
  final AppIcon actionIcon;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GlassIconButton(icon: AppIcon.back, label: 'Back to home', onTap: onBack),
        Semantics(header: true, child: Text(title, style: txt(17, weight: FontWeight.w500))),
        GlassIconButton(icon: actionIcon, label: actionLabel, onTap: onAction),
      ],
    );
  }
}

/// A soft blurred color blob for the ambient background.
class Blob {
  const Blob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.centerX = false,
    required this.width,
    required this.height,
    required this.color,
    required this.opacity,
    this.stop = 0.68,
  });

  final double? top, left, right, bottom;
  final bool centerX;
  final double width, height;
  final Color color;
  final double opacity;
  final double stop;
}

/// Screen background: near-black with soft grey light blobs behind the glass.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.blobs, required this.child});

  final List<Blob> blobs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: AppColors.background)),
          for (final b in blobs)
            Positioned(
              top: b.top,
              bottom: b.bottom,
              left: b.centerX ? (constraints.maxWidth - b.width) / 2 : b.left,
              right: b.centerX ? null : b.right,
              width: b.width,
              height: b.height,
              child: IgnorePointer(
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [b.color.withValues(alpha: b.opacity), b.color.withValues(alpha: 0)],
                        stops: [0, b.stop],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(child: child),
        ],
      );
    });
  }
}

/// Scrollable screen body with the design's 20px side gutter and top inset.
class ScreenScroll extends StatelessWidget {
  const ScreenScroll({
    super.key,
    required this.children,
    this.gap = 16,
    this.bottomInset = 120,
  });

  final List<Widget> children;
  final double gap;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 16;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, top, 20, bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Pill chip; [selected] renders the solid light style.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.height = 40,
    this.horizontalPadding = 16,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final double height;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      style: txt(13,
          weight: selected ? FontWeight.w500 : FontWeight.w400,
          color: selected ? AppColors.background : AppColors.text),
    );
    final content = Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Center(widthFactor: 1, child: text),
    );
    return Tap(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        child: selected
            ? Container(
                key: const ValueKey(true),
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.text,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
                child: content,
              )
            : Glass(
                key: const ValueKey(false),
                height: height,
                radius: height / 2,
                child: content,
              ),
      ),
    );
  }
}

/// Segmented control: equal-width options inside a rounded track.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.height = 42,
    this.fontSize = 14,
    this.trackColor,
    this.glass = false,
  });

  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final double height;
  final double fontSize;
  final Color? trackColor;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.all(glass ? 5 : 4),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segment(options[i])),
          ],
        ],
      ),
    );
    if (glass) return Glass(radius: 24, child: row);
    return Container(
      decoration: BoxDecoration(
        color: trackColor ?? const Color(0x38000000),
        borderRadius: BorderRadius.circular(height / 2 + 4),
      ),
      child: row,
    );
  }

  Widget _segment((T, String) option) {
    final selected = option.$1 == value;
    return Tap(
      onTap: () => onChanged(option.$1),
      semanticLabel: option.$2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.text : Colors.transparent,
          borderRadius: BorderRadius.circular(height / 2 - 1),
        ),
        child: Text(
          option.$2,
          style: txt(fontSize,
              weight: selected ? FontWeight.w500 : FontWeight.w400,
              color: selected ? AppColors.background : AppColors.soft),
        ),
      ),
    );
  }
}

/// On/off switch styled like the design (accent track, dark knob when on).
class PillSwitch extends StatelessWidget {
  const PillSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 50,
    this.height = 30,
    this.label,
    this.expandTouchTarget = true,
  });

  final bool value;
  final bool expandTouchTarget;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final knob = height - (height >= 30 ? 8 : 6);
    final inset = (height - knob) / 2;
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Padding(
          // Keeps the touch target at least 44px tall.
          padding: EdgeInsets.symmetric(vertical: expandTouchTarget ? ((44 - height) / 2).clamp(0, 22) : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: value ? AppColors.accent : const Color(0x24FFFFFF),
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(inset),
                child: Container(
                  width: knob,
                  height: knob,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? AppColors.background : AppColors.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Atlas's glowing orb.
class AtlasOrb extends StatelessWidget {
  const AtlasOrb({super.key, required this.size, this.glow = 24, this.glowOpacity = 0.45});

  final double size;
  final double glow;
  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [Color(0xFFFFFFFF), Color(0xFFD6E9FF), Color(0xFF86AEDB), Color(0xFF3C475B), Color(0xFF1A1E26)],
          stops: [0, 0.16, 0.42, 0.74, 1],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.accent.withValues(alpha: glowOpacity), blurRadius: glow),
        ],
      ),
    );
  }
}

/// Small status dot.
class Dot extends StatelessWidget {
  const Dot({super.key, required this.color, this.size = 7, this.glow = false});

  final Color color;
  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glow ? [BoxShadow(color: color, blurRadius: 10)] : null,
      ),
    );
  }
}

/// Muted section label, e.g. "Scenes", "Locks".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(text, style: txt(13, color: AppColors.muted)),
          ?trailing,
        ],
      ),
    );
  }
}

/// A thin divider between rows inside a glass list.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(color: AppColors.divider, child: SizedBox(height: 1, width: double.infinity));
}

// ---------------------------------------------------------------------------
// Toast for features that aren't designed or built yet.

OverlayEntry? _toastEntry;
Timer? _toastTimer;

void showToast(BuildContext context, String message) {
  final overlay = Overlay.of(context, rootOverlay: true);
  _toastTimer?.cancel();
  _toastEntry?.remove();
  final entry = OverlayEntry(builder: (context) => _Toast(message: message));
  _toastEntry = entry;
  overlay.insert(entry);
  _toastTimer = Timer(const Duration(milliseconds: 1800), () {
    entry.remove();
    if (_toastEntry == entry) _toastEntry = null;
  });
}

void comingSoon(BuildContext context, [String? what]) {
  showToast(context, what == null ? 'Coming soon' : '$what · coming soon');
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 120;
    return Positioned(
      left: 20,
      right: 20,
      bottom: bottom,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 200),
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
            ),
            child: Glass(
              radius: 20,
              fill: const Color(0xCC1A1B1F),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Text(message, style: txt(13)),
            ),
          ),
        ),
      ),
    );
  }
}
