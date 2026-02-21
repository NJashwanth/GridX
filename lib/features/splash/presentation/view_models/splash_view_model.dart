import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../app/providers/app_providers.dart';

final splashViewModelProvider = Provider<SplashViewModel>((ref) {
  return SplashViewModel(ref);
});

class SplashViewModel {
  SplashViewModel(this.ref);

  final Ref ref;

  Future<void> completeSplash() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    ref.read(showSplashProvider.notifier).state = false;
  }
}
