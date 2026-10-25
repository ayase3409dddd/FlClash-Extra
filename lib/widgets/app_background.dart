import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/wallpaper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxDimStrength = 0.85;
const _maxBlurSigma = 30.0;
const _fadeDuration = Duration(milliseconds: 560);

BoxFit _fitOf(BackgroundFitMode mode) => switch (mode) {
  BackgroundFitMode.fill => BoxFit.cover,
  BackgroundFitMode.stretch => BoxFit.fill,
  BackgroundFitMode.fit => BoxFit.contain,
};

/// Paints the wallpaper set in the theme settings behind [child].
///
/// Only the background settings live here: the advanced material is a surface
/// treatment of its own. The fade keeps page surfaces clear through a
/// [Wallpaper] while it runs, and eases rather than switching.
class AppBackground extends ConsumerStatefulWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends ConsumerState<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _fadeDuration,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  bool _target = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setTarget(bool target) {
    if (target == _target) {
      return;
    }
    _target = target;
    if (target) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _layer({
    required String path,
    required BackgroundFitMode fit,
    required double dim,
    required double blur,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: _fade,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(path),
                key: ValueKey<String>(path),
                fit: _fitOf(fit),
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
              ColoredBox(color: Colors.black.withValues(alpha: dim)),
              if (blur > 0)
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: const SizedBox.expand(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final setting = ref.watch(
      appSettingProvider.select(
        (state) => (
          enabled: state.backgroundEnabled,
          path: state.backgroundImagePath,
          fit: state.backgroundFitMode,
          brightness: state.backgroundBrightness,
          blur: state.backgroundBlur,
        ),
      ),
    );
    final path = setting.path;
    _setTarget(setting.enabled && path != null && path.isNotEmpty);
    final showing = _target || _controller.isAnimating || _controller.value > 0;
    if (!showing || path == null || path.isEmpty || !File(path).existsSync()) {
      return widget.child;
    }
    final dim = clampDouble(setting.brightness, 0, 1) * _maxDimStrength;
    final blur = clampDouble(setting.blur, 0, _maxBlurSigma);
    final backdrop = ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: _layer(path: path, fit: setting.fit, dim: dim, blur: blur),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: IgnorePointer(child: backdrop)),
        Wallpaper(visible: showing, backdrop: backdrop, child: widget.child),
      ],
    );
  }
}
