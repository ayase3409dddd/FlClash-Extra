import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:material_ui/material_ui.dart';

/// The frosted-material setting, shared through the theme so ui widgets can
/// read it without touching app settings.
class MaterialFrost extends ThemeExtension<MaterialFrost> {
  const MaterialFrost({
    required this.enabled,
    required this.blur,
    required this.dim,
  });

  final bool enabled;
  final double blur;
  final double dim;

  static MaterialFrost? of(BuildContext context) =>
      Theme.of(context).extension<MaterialFrost>();

  @override
  MaterialFrost copyWith({bool? enabled, double? blur, double? dim}) =>
      MaterialFrost(
        enabled: enabled ?? this.enabled,
        blur: blur ?? this.blur,
        dim: dim ?? this.dim,
      );

  @override
  MaterialFrost lerp(MaterialFrost? other, double t) {
    if (other == null) {
      return this;
    }
    return MaterialFrost(
      enabled: t < 0.5 ? enabled : other.enabled,
      blur: lerpDouble(blur, other.blur, t)!,
      dim: lerpDouble(dim, other.dim, t)!,
    );
  }
}

/// Blurs what lies behind [child] while the surface above it stays
/// translucent, frosting any card drawn through it.
class Frosted extends StatelessWidget {
  const Frosted({super.key, required this.shape, required this.child});

  final ShapeBorder shape;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final frost = MaterialFrost.of(context);
    final nested =
        context.dependOnInheritedWidgetOfExactType<_FrostedScope>() != null;
    if (frost == null || !frost.enabled || frost.blur <= 0 || nested) {
      return child;
    }
    return _FrostedScope(
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: shape),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: frost.blur, sigmaY: frost.blur),
          child: child,
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
