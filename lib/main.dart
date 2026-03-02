import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:lifecycle_logger/lifecycle_logger.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LifecycleLogger.attach();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GridXApp();
  }
}
