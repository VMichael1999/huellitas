import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalWidgetsLocalizations;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/connectivity_cubit.dart';
import '../core/theme/hu_tokens.dart';
import '../core/utils/clock.dart';
import '../core/widgets/hu_widgets.dart';
import '../core/widgets/toaster.dart';
import '../features/appointments/appointments_bloc.dart';
import '../features/auth/session_bloc.dart';
import '../features/booking/booking_bloc.dart';
import '../features/chat/chat_bloc.dart';
import '../features/notifications/notifications_cubit.dart';
import '../features/pets/pet_wizard_bloc.dart';
import '../features/pets/pets_bloc.dart';
import '../features/reminders/reminders_bloc.dart';
import '../features/services/service_booking_bloc.dart';
import '../features/shop/cart_bloc.dart';
import '../features/shop/checkout_bloc.dart';
import '../features/shop/shop_cubit.dart';
import '../features/vets/vets_cubit.dart';
import '../features/walk/live_walk_bloc.dart';
import 'di.dart';
import 'router.dart';

/// Pantalla 30: Sin conexión (`OfflineView` sobre cualquier pantalla cuando `ConnectivityCubit` está desconectado).
class OfflineView extends StatelessWidget {
  const OfflineView({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state.online) return const SizedBox.shrink();
        return Positioned.fill(
          child: Material(
            color: t.bg,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    EmptyState(
                      artKey: 'a-dog',
                      title: 'Sin conexión',
                      subtitle:
                          'Revisa tu internet. Las fichas de tus mascotas siguen disponibles.',
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: HuButton(
                        label: 'Reintentar',
                        loading: state.retrying,
                        onPressed: () async {
                          final ok =
                              await context.read<ConnectivityCubit>().retry();
                          if (!ok) {
                            getIt<Toaster>().show('Todavía sin conexión.');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HuellitasApp extends StatefulWidget {
  const HuellitasApp({super.key, this.initialRoute = '/splash'});
  final String initialRoute;

  @override
  State<HuellitasApp> createState() => _HuellitasAppState();
}

class _HuellitasAppState extends State<HuellitasApp> {
  late final GoRouter _router =
      buildHuRouter(initialLocation: widget.initialRoute);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clock = getIt<Clock>();
    final toaster = getIt<Toaster>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SessionBloc()),
        BlocProvider(create: (_) => PetsBloc(clock: clock)),
        BlocProvider(create: (_) => PetWizardBloc()),
        BlocProvider(create: (_) => AppointmentsBloc(clock: clock)),
        BlocProvider(create: (_) => BookingBloc(clock: clock)),
        BlocProvider(create: (_) => VetsCubit()),
        BlocProvider(create: (_) => ServiceBookingBloc(clock: clock)),
        BlocProvider(create: (_) => LiveWalkBloc(clock: clock)),
        BlocProvider(create: (_) => ChatBloc(clock: clock)),
        BlocProvider(create: (_) => RemindersBloc(clock: clock)),
        BlocProvider(create: (_) => NotificationsCubit(clock: clock)),
        BlocProvider(create: (_) => ShopCubit()),
        BlocProvider(create: (_) => CartBloc(clock: clock)),
        BlocProvider(create: (_) => CheckoutBloc()),
        BlocProvider(create: (_) => ConnectivityCubit()),
      ],
      child: MaterialApp.router(
        title: 'Huellitas',
        debugShowCheckedModeBanner: false,
        theme: buildHuTheme(),
        routerConfig: _router,
        locale: const Locale('es', '419'),
        supportedLocales: const [Locale('es', '419'), Locale('es')],
        localizationsDelegates: const [
          ...GlobalMaterialLocalizations.delegates,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => Stack(
          children: [
            Positioned.fill(child: child ?? const SizedBox.shrink()),
            const OfflineView(),
            HuToastHost(toaster: toaster),
          ],
        ),
      ),
    );
  }
}
