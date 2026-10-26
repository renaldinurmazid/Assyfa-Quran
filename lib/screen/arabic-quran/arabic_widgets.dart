import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:quran_app/theme/font.dart';

/// "#RRGGBB" / "#AARRGGBB" from the admin colour pickers; [fallback] when unparsable.
Color arabicColor(String? hex, {Color fallback = const Color(0xFF6C5CE7)}) {
  if (hex == null) return fallback;
  var value = hex.replaceAll('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? fallback : Color(parsed);
}

TextStyle arabicTextStyle({
  double size = 28,
  Color? color,
  FontWeight weight = FontWeight.w600,
}) {
  return TextStyle(
    fontFamily: 'LPMQ',
    fontSize: size,
    fontWeight: weight,
    height: 1.9,
    color: color,
  );
}

/// Rounded network image that disappears quietly when it fails to load.
class ArabicImage extends StatelessWidget {
  final String url;
  final double? height;
  final BoxFit fit;
  final double radius;

  const ArabicImage({
    super.key,
    required this.url,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: double.infinity,
        fit: fit,
        placeholder: (_, __) => Container(
          height: height ?? 120,
          color: context.theme.colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Plays one audio URL; tapping again stops it.
class ArabicAudioButton extends StatefulWidget {
  final String url;
  final Color color;
  final double size;

  const ArabicAudioButton({
    super.key,
    required this.url,
    required this.color,
    this.size = 40,
  });

  @override
  State<ArabicAudioButton> createState() => _ArabicAudioButtonState();
}

class _ArabicAudioButtonState extends State<ArabicAudioButton> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _sub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    try {
      if (_playing) {
        await _player.stop();
      } else {
        await _player.play(UrlSource(widget.url));
      }
    } catch (_) {
      // An unreachable file simply does not play.
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _toggle,
      customBorder: const CircleBorder(),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: _playing ? 0.22 : 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color.withValues(alpha: 0.35)),
        ),
        child: Icon(
          _playing ? LucideIcons.square : LucideIcons.volume2,
          color: widget.color,
          size: widget.size * 0.55,
        ),
      ),
    );
  }
}

/// Small rounded label used for kinds, durations and XP.
class ArabicChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const ArabicChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: pSemiBold10.copyWith(color: color)),
        ],
      ),
    );
  }
}

class ArabicShimmerBox extends StatelessWidget {
  final double height;
  const ArabicShimmerBox({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.6,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// Fade + slide-up on first build; [delay] staggers siblings.
class ArabicReveal extends StatelessWidget {
  final Widget child;
  final int delay;
  const ArabicReveal({super.key, required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delay * 120),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Gradient hero card (with soft glow shapes) tinted by [color]. Content is white-on-colour.
class ArabicGradientCard extends StatelessWidget {
  final Color color;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ArabicGradientCard({
    super.key,
    required this.color,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(color, Colors.white, 0.1)!,
              Color.lerp(color, Colors.black, 0.35)!,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(right: -40, top: -50, child: _glow(170, 0.10)),
            Positioned(left: -30, bottom: -60, child: _glow(140, 0.07)),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}

/// Card surface used across the Arabic course: white / dark surface, soft border and shadow.
BoxDecoration arabicCardDecoration(
  BuildContext context, {
  Color? accent,
  double radius = 20,
}) {
  final scheme = context.theme.colorScheme;
  final isDark = context.isDarkMode;
  return BoxDecoration(
    color: isDark ? scheme.surfaceContainer : Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: accent != null
          ? accent.withValues(alpha: 0.3)
          : scheme.outlineVariant.withValues(alpha: 0.35),
    ),
    boxShadow: isDark || accent == null
        ? null
        : [
            BoxShadow(
              color: accent.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
  );
}
