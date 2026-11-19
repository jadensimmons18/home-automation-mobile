import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/home_state.dart';
import '../state/models.dart';
import '../state/nav_state.dart';
import '../theme.dart';
import '../widgets/app_icons.dart';
import '../widgets/glass.dart';
import 'shell.dart';

class AtlasScreen extends StatefulWidget {
  const AtlasScreen({super.key});

  @override
  State<AtlasScreen> createState() => _AtlasScreenState();
}

class _AtlasScreenState extends State<AtlasScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    context.read<HomeState>().sendMessage(text);
    _input.clear();
  }

  void _scrollToEndSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeState>();
    final itemCount = home.messages.length + (home.atlasTyping ? 1 : 0);
    if (itemCount != _lastCount) {
      _lastCount = itemCount;
      _scrollToEndSoon();
    }

    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    // Input bar sits above the nav bar, or above the keyboard when it's open.
    final inputBottom = keyboard > 0 ? keyboard + 12 : Shell.contentBottomInset(context) - 12;
    const inputHeight = 60.0;

    return AmbientBackground(
      blobs: const [
        Blob(top: 40, centerX: true, width: 460, height: 420, color: Color(0xFF8EAAD2), opacity: 0.30, stop: 0.65),
        Blob(bottom: -180, right: -140, width: 420, height: 420, color: Color(0xFF8C92A0), opacity: 0.32),
      ],
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, media.padding.top + 16, 20, 0),
                  child: ScreenHeader(
                    title: 'Atlas',
                    onBack: () {
                      _focus.unfocus();
                      context.read<NavState>().go(AppTab.home);
                    },
                    actionIcon: AppIcon.clock,
                    actionLabel: 'Conversation history',
                    onAction: () => comingSoon(context, 'Conversation history'),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    padding: EdgeInsets.fromLTRB(20, 16, 20, inputBottom + inputHeight + 16),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      _Intro(rooms: home.atlasRooms),
                      const SizedBox(height: 16),
                      for (final m in home.messages) ...[
                        _Bubble(message: m),
                        const SizedBox(height: 10),
                      ],
                      if (home.atlasTyping) ...[
                        const _TypingBubble(),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in home.atlasSuggestions)
                            Pill(label: s, height: 36, horizontalPadding: 14, onTap: () => _send(s)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: inputBottom,
            child: Glass(
              height: inputHeight,
              radius: 30,
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      focusNode: _focus,
                      style: txt(15),
                      cursorColor: AppColors.accent,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Message Atlas',
                        hintStyle: txt(15, color: const Color(0x8CF2F3F5)),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _input.text.trim().isEmpty
                      ? _RoundAccentButton(
                          icon: AppIcon.mic,
                          label: 'Speak to Atlas',
                          onTap: () => comingSoon(context, 'Voice'),
                        )
                      : _RoundAccentButton(
                          icon: AppIcon.send,
                          label: 'Send message',
                          onTap: () => _send(_input.text),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAccentButton extends StatelessWidget {
  const _RoundAccentButton({required this.icon, required this.label, required this.onTap});

  final AppIcon icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tap(
      semanticLabel: label,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
        child: Center(child: AppIconView(icon, color: AppColors.background, strokeWidth: 1.8)),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.rooms});

  final List<String> rooms;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x06FFFFFF),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(child: AtlasOrb(size: 112, glow: 60)),
          ),
          const SizedBox(height: 14),
          Text('How can I help?', style: txt(22, weight: FontWeight.w500, tracking: -0.01)),
          const SizedBox(height: 4),
          Text('Listening on ${rooms.join(' and ')}', style: txt(13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 40;
    if (message.fromUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xEBF2F3F5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Text(message.text, style: txt(15, color: AppColors.background)),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width * 0.88),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
            bottomRight: Radius.circular(22),
            bottomLeft: Radius.circular(6),
          ),
          child: Glass(
            radius: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message.text, style: txt(15, height: 1.45)),
                if (message.checklist.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  for (final item in message.checklist)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const AppIconView(AppIcon.check, size: 16, color: AppColors.good, strokeWidth: 2),
                          const SizedBox(width: 10),
                          Flexible(child: Text(item, style: txt(13, color: const Color(0xCCF2F3F5)))),
                        ],
                      ),
                    ),
                ],
                if (message.actionLabel != null) ...[
                  const SizedBox(height: 4),
                  Tap(
                    semanticLabel: message.actionLabel,
                    onTap: () => comingSoon(context, 'Saving scenes'),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(color: const Color(0x24FFFFFF)),
                      ),
                      child: Center(widthFactor: 1, child: Text(message.actionLabel!, style: txt(13))),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        label: 'Atlas is replying',
        child: Glass(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Opacity(
                    opacity: 0.3 + 0.7 * (((_c.value * 3 - i) % 3) < 1 ? 1 : 0),
                    child: const Dot(color: AppColors.text, size: 6),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
