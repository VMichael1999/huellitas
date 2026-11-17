import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/widgets/toaster.dart';
import '../features/appointments/appointments_pages.dart';
import '../features/auth/auth_pages.dart';
import '../features/booking/booking_pages.dart';
import '../features/chat/chat_pages.dart';
import '../features/home/home_page.dart';
import '../features/notifications/notifications_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/pets/pet_pages.dart';
import '../features/profile/profile_pages.dart';
import '../features/reminders/reminders_page.dart';
import '../features/services/services_pages.dart';
import '../features/shop/shop_pages.dart';
import '../features/sos/sos_page.dart';
import '../features/splash/splash_page.dart';
import '../features/vets/vets_pages.dart';
import '../features/walk/live_walk_page.dart';
import 'di.dart';
import 'shell_page.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class _ToastDismissObserver extends NavigatorObserver {
  void _dismiss() {
    if (getIt.isRegistered<Toaster>()) {
      getIt<Toaster>().hide();
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _dismiss();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _dismiss();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _dismiss();
}

Page<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 240),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

GoRouter buildHuRouter({String initialLocation = '/splash'}) {
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    observers: [_ToastDismissObserver()],
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (c, s) => _fadePage(s, const SplashPage()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (c, s) => _fadePage(s, const OnboardingPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (c, s) => _fadePage(s, const LoginPage()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (c, s) => _fadePage(s, const SignupPage()),
      ),
      GoRoute(
        path: '/pet/new',
        pageBuilder: (c, s) => _fadePage(s, const PetNewWizardPage()),
      ),
      GoRoute(
        path: '/pet',
        pageBuilder: (c, s) => _fadePage(s, const PetProfilePage()),
      ),
      GoRoute(
        path: '/book',
        pageBuilder: (c, s) => _fadePage(s, const BookAppointmentPage()),
      ),
      GoRoute(
        path: '/done',
        pageBuilder: (c, s) => _fadePage(s, const DonePage()),
      ),
      GoRoute(
        path: '/appt',
        pageBuilder: (c, s) => _fadePage(s, const AppointmentDetailPage()),
      ),
      GoRoute(
        path: '/vets',
        pageBuilder: (c, s) => _fadePage(s, const VetsNearPage()),
      ),
      GoRoute(
        path: '/vet',
        pageBuilder: (c, s) => _fadePage(s, const VetProfilePage()),
      ),
      GoRoute(
        path: '/services',
        pageBuilder: (c, s) => _fadePage(s, const ServicesListPage()),
      ),
      GoRoute(
        path: '/service/book',
        pageBuilder: (c, s) => _fadePage(s, const ServiceBookingPage()),
      ),
      GoRoute(
        path: '/walk',
        pageBuilder: (c, s) => _fadePage(s, const LiveWalkPage()),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (c, s) => _fadePage(s, const ChatPage()),
      ),
      GoRoute(
        path: '/reminders',
        pageBuilder: (c, s) => _fadePage(s, const RemindersPage()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (c, s) => _fadePage(s, const NotificationsPage()),
      ),
      GoRoute(
        path: '/shop',
        pageBuilder: (c, s) => _fadePage(s, const ShopPage()),
      ),
      GoRoute(
        path: '/product',
        pageBuilder: (c, s) => _fadePage(s, const ProductDetailPage()),
      ),
      GoRoute(
        path: '/cart',
        pageBuilder: (c, s) => _fadePage(s, const CartPage()),
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (c, s) => _fadePage(s, const CheckoutPage()),
      ),
      GoRoute(
        path: '/sos',
        pageBuilder: (c, s) => _fadePage(s, const SosPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          if (getIt.isRegistered<Toaster>()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              getIt<Toaster>().hide();
            });
          }
          return ShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (c, s) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/appts',
                builder: (c, s) => const AppointmentsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pets',
                builder: (c, s) => const PetsListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/msgs',
                builder: (c, s) => const MessagesListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (c, s) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  return router;
}
