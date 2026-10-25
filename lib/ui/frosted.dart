import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:material_ui/material_ui.dart';

/// The frosted-material setting, shared through the theme so ui widgets can
/// read it without touching app settings.
class MaterialFrost extends ThemeExtension<MaterialFrost> {
  const MaterialFrost({
    required this.enabled,
    required this.blur,
    required this.opacity,
  });

  final bool enabled;
  final double blur;

  /// How see-through the frosted surface is, 0 to 1.
  final double opacity;

  static MaterialFrost? of(BuildContext context) =>
      Theme.of(context).extension<MaterialFrost>();

  @override
  MaterialFrost copyWith({bool? enabled, double? blur, double? opacity}) =>
      MaterialFrost(
        enabled: enabled ?? this.enabled,
        blur: blur ?? this.blur,
        opacity: opacity ?? this.opacity,
      );

  @override
  MaterialFrost lerp(MaterialFrost? other, double t) {
    if (other == null) {
      return this;
    }
    return MaterialFrost(
      enabled: t < 0.5 ? enabled : other.enabled,
      blur: lerpDouble(blur, other.blur, t)!,
      opacity: lerpDouble(opacity, other.opacity, t)!,
    );
  }
}

/// Blurs what lies behind [child] and lays a glass sheen under it, frosting
/// any card drawn through it. Liquid-glass widgets do not use this.
class Frosted extends StatelessWidget {
  const Frosted({
    super.key,
    required this.shape,
    required this.child,
    this.force = false,
  });

  final ShapeBorder shape;
  final Widget child;

  /// Frosts even inside another [Frosted], for a small piece that sits on a
  /// card and should read as glass of its own.
  final bool force;

  @override
  Widget build(BuildContext context) {
    final frost = MaterialFrost.of(context);
    final nested =
        context.dependOnInheritedWidgetOfExactType<_FrostedScope>() != null;
    if (frost == null ||
        !frost.enabled ||
        frost.blur <= 0 ||
        (nested && !force)) {
      return child;
    }
    return _FrostedScope(
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: frost.blur,
                  sigmaY: frost.blur,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _FrostedScope extends InheritedWidget {
  const _FrostedScope({required super.child});

  @override
  bool updateShouldNotify(_FrostedScope oldWidget) => false;
}
