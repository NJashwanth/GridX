import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/providers/app_providers.dart';

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  return HomeViewModel(ref);
});

class HomeViewModel {
  HomeViewModel(this.ref);

  final Ref ref;

  ThemeMode get currentThemeMode => ref.read(themeModeProvider);

  void toggleTheme() {
    final current = ref.read(themeModeProvider);
    ref.read(themeModeProvider.notifier).state = current == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}
