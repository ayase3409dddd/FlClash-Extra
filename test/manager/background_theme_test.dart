import 'package:fl_clash/manager/theme_manager.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/ui/surface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

class _TestAppSetting extends AppSetting {
  @override
  AppSettingProps build() => const AppSettingProps();
}

void main() {
  testWidgets('the theme stays opaque while a picture is shown', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [appSettingProvider.overrideWith(_TestAppSetting.new)],
    );
    addTearDown(container.dispose);
    late ThemeData theme;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            theme = watchAppTheme(ref, Brightness.light);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(theme.colorScheme.surface.a, 1.0);
    expect(theme.scaffoldBackgroundColor.a, 1.0);

    container.read(appSettingProvider.notifier).value = const AppSettingProps(
      backgroundEnabled: true,
      backgroundImagePath: '/background.png',
      backgroundBrightness: 0.4,
    );
    await tester.pump();

    // Pages clear their own fill through Wallpaper instead, so the scheme and
    // every surface that shares it keep full contrast.
    expect(theme.colorScheme.surface.a, 1.0);
    expect(theme.colorScheme.surfaceContainer.a, 1.0);
    expect(theme.scaffoldBackgroundColor.a, 1.0);

    container.read(appSettingProvider.notifier).value = const AppSettingProps(
      advancedMaterialEnabled: true,
      advancedMaterialOpacity: 0.5,
    );
    await tester.pump();

    // The material is a surface treatment: the scheme, and with it every
    // liquid-glass component, stays opaque; only the levels turn translucent.
    expect(theme.colorScheme.surface.a, 1.0);
    expect(theme.colorScheme.surfaceContainer.a, 1.0);
    expect(SurfaceLevel.card.colorOf(theme.colorScheme).a, lessThan(1.0));

    container.read(appSettingProvider.notifier).value = const AppSettingProps();
    await tester.pump();
    expect(SurfaceLevel.card.colorOf(theme.colorScheme).a, 1.0);
  });
}
