import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/app_providers.dart';
import '../core/theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/splash/presentation/pages/splash_page.dart';

class GridXApp extends ConsumerWidget {
  const GridXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSplash = ref.watch(showSplashProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'GridX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: showSplash ? const SplashPage() : const HomePage(),
      ),
    );
  }
}
