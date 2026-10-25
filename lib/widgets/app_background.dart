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

/// Paints the wallpaper, or the frosted material backdrop, behind [child].
///
/// It owns the fade as well: page surfaces clear their fill through a
/// [Wallpaper] while the backdrop is on its way in or out, and the fade curve
/// is eased rather than linear.
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

  Widget _backdrop(
    BuildContext context, {
    required bool imageVisible,
    required bool advanced,
    required String? path,
    required BackgroundFitMode fit,
    required double imageDim,
    required double materialDim,
    required double blur,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final image = imageVisible && path != null && path.isNotEmpty
        ? File(path)
        : null;
    final picture = image != null && image.existsSync()
        ? Image.file(
            image,
            key: ValueKey<String>(path!),
            fit: _fitOf(fit),
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primary.withValues(alpha: 0.55),
                  scheme.surfaceContainerHighest,
                  scheme.tertiary.withValues(alpha: 0.4),
                ],
              ),
            ),
          );
    final dim = clampDouble(imageDim + materialDim, 0, 0.92);
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: scheme.surface),
        picture,
        if (blur > 0 && advanced)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: const SizedBox.expand(),
            ),
          ),
        ColoredBox(color: Colors.black.withValues(alpha: dim)),
        if (blur > 0 && !advanced)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: const SizedBox.expand(),
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
          advanced: state.advancedMaterialEnabled,
          materialDim: state.advancedMaterialDim,
          materialBlur: state.advancedMaterialBlur,
        ),
      ),
    );
    final path = setting.path;
    final imageVisible = setting.enabled && path != null && path.isNotEmpty;
    final advanced = setting.advanced;
    final target = imageVisible || advanced;
    _setTarget(target);
    final showing = _target || _controller.isAnimating || _controller.value > 0;
    if (!showing) {
      return widget.child;
    }
    if (imageVisible && !File(path).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Theme.of(context).colorScheme.surface),
          Wallpaper(visible: _target, child: widget.child),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _fade,
              child: _backdrop(
                context,
                imageVisible: imageVisible,
                advanced: advanced,
                path: path,
                fit: setting.fit,
                imageDim: imageVisible
                    ? clampDouble(setting.brightness, 0, 1) * _maxDimStrength
                    : 0,
                materialDim: advanced
                    ? clampDouble(setting.materialDim, 0, 1) * 0.35
                    : 0,
                blur: advanced
                    ? clampDouble(setting.materialBlur, 0, _maxBlurSigma)
                    : clampDouble(setting.blur, 0, _maxBlurSigma),
              ),
            ),
          ),
        ),
        Wallpaper(visible: _target, child: widget.child),
      ],
    );
  }
}
