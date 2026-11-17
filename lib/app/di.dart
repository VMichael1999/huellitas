import 'package:get_it/get_it.dart';

import '../core/utils/clock.dart';
import '../core/widgets/toaster.dart';

final GetIt getIt = GetIt.instance;

void setupDi({Clock? clock}) {
  if (getIt.isRegistered<Clock>()) {
    getIt.unregister<Clock>();
  }
  if (getIt.isRegistered<Toaster>()) {
    getIt.unregister<Toaster>();
  }
  getIt.registerSingleton<Clock>(clock ?? const SystemClock());
  getIt.registerSingleton<Toaster>(Toaster());
}
