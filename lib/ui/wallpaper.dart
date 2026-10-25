import 'package:flutter/widgets.dart';

/// Lets page-level surfaces clear their fill while a background is shown, so
/// the picture reaches the pages while cards and sheets stay solid.
class Wallpaper extends InheritedWidget {
  const Wallpaper({
    super.key,
    required this.visible,
    this.backdrop,
    required super.child,
  });

  final bool visible;

  /// The painted backdrop, reused by pushed routes so they keep the configured
  /// background instead of showing the page underneath.
  final Widget? backdrop;

  static Wallpaper? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Wallpaper>();

  static bool visibleOf(BuildContext context) => of(context)?.visible ?? false;

  static Widget? backdropOf(BuildContext context) => of(context)?.backdrop;

  @override
  bool updateShouldNotify(Wallpaper oldWidget) =>
      visible != oldWidget.visible || backdrop != oldWidget.backdrop;
}
