import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/home_state.dart';
import '../state/models.dart';
import '../state/nav_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';
import 'shell.dart';

class EnergyScreen extends StatefulWidget {
  const EnergyScreen({super.key});

  @override
  State<EnergyScreen> createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  EnergyRange _range = EnergyRange.day;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();
    final series = home.energy[_range]!;
    final monthTotal = double.tryParse(home.energy[EnergyRange.month]!.total) ?? 0;
    final rate = home.ratePerKwh;
    final maxDevice = home.topDevices.map((d) => d.kwh).reduce((a, b) => a > b ? a : b);

    return AmbientBackground(
      blobs: const [
        Blob(top: -140, right: -100, width: 440, height: 420, color: Color(0xFFA09C94), opacity: 0.26, stop: 0.66),
        Blob(bottom: -120, left: -140, width: 440, height: 420, color: Color(0xFF8C94A6), opacity: 0.32),
      ],
      child: ScreenScroll(
        bottomInset: Shell.contentBottomInset(context),
        children: [
          ScreenHeader(
            title: 'Energy',
            onBack: () => context.read<NavState>().go(AppTab.home),
            actionIcon: AppIcon.sliders,
            actionLabel: 'Filter',
            onAction: () => comingSoon(context, 'Energy filters'),
          ),

          // ---- Usage chart ----
          Glass(
            radius: 28,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(series.label, style: txt(13, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(text: series.total),
                              TextSpan(
                                text: ' kWh',
                                style: txt(16, color: AppColors.muted),
                              ),
                            ]),
                            style: txt(44, weight: FontWeight.w200, tracking: -0.04, height: 1),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.good.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(series.comparison, style: txt(12, color: AppColors.good)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExcludeSemantics(child: _Bars(values: series.values)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final a in series.axis) Text(a, style: txt(11, color: const Color(0x8CF2F3F5))),
                  ],
                ),
                const SizedBox(height: 16),
                Segmented<EnergyRange>(
                  height: 36,
                  fontSize: 13,
                  options: const [
                    (EnergyRange.day, 'Day'),
                    (EnergyRange.week, 'Week'),
                    (EnergyRange.month, 'Month'),
                  ],
                  value: _range,
                  onChanged: (r) => setState(() => _range = r),
                ),
              ],
            ),
          ),

          // ---- Now / estimate ----
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Using now',
                  value: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '${home.usingNowKw} '),
                      TextSpan(text: 'kW', style: txt(13, color: AppColors.muted)),
                    ]),
                    style: txt(24, weight: FontWeight.w300),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Est. this month',
                  value: rate == null
                      ? Text('Set rate', style: txt(24, weight: FontWeight.w300, color: AppColors.muted))
                      : Text('\$${(monthTotal * rate).toStringAsFixed(0)}', style: txt(24, weight: FontWeight.w300)),
                  onTap: rate == null ? () => comingSoon(context, 'Electricity rate setting') : null,
                ),
              ),
            ],
          ),

          // ---- Top devices ----
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Top devices today'),
              const SizedBox(height: 8),
              Glass(
                radius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    for (final d in home.topDevices)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(d.name, style: txt(14)),
                                Text('${d.kwh} kWh',
                                    style: txt(14, color: AppColors.soft, features: tabularFigures)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.divider,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: d.kwh / maxDevice,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _Bars extends StatelessWidget {
  const _Bars({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, v) in values.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: TweenAnimationBuilder<double>(
                key: ValueKey('${values.length}-$i'),
                tween: Tween(begin: 0, end: v / max),
                duration: Duration(milliseconds: 300 + i * 8),
                curve: Curves.easeOutCubic,
                builder: (context, f, _) => Container(
                  height: 120 * f,
                  decoration: BoxDecoration(
                    color: i == values.length - 1 ? AppColors.accent : const Color(0x47F2F3F5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.onTap});

  final String label;
  final Widget value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Glass(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: txt(12, color: AppColors.muted)),
          const SizedBox(height: 6),
          value,
        ],
      ),
    );
    return onTap == null ? card : Tap(semanticLabel: label, onTap: onTap, child: card);
  }
}
