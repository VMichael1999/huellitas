import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/connectivity_cubit.dart';
import '../../core/data/demo_data.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../auth/session_bloc.dart';
import '../chat/chat_bloc.dart';
import '../notifications/notifications_cubit.dart';
import '../pets/pets_bloc.dart';
import '../reminders/reminders_bloc.dart';
import '../shop/cart_bloc.dart';
import '../walk/live_walk_bloc.dart';

/// Pantalla 28: Perfil (`s-profile`).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _openOrdersSheet(BuildContext context) {
    final orders = context.read<CartBloc>().state.orders;
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mis pedidos',
              style: t.style(23, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 14),
            for (final o in orders)
              HuCard(
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const IconBox(
                      icon: 'i-bag',
                      accent: HuAccent.sun,
                      size: 42,
                      radius: 14,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.id,
                            style: t.style(15.5, FontWeight.w600, t.ink),
                          ),
                          Text(
                            '${HuFormat.fDate(o.date)} · ${o.items} productos',
                            style: t.style(13, FontWeight.w600, t.ink2),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Money.usd2(o.total),
                          style: t.style(15, FontWeight.w600, t.ink),
                        ),
                        Text(
                          o.status,
                          style: t.style(11.5, FontWeight.w600, t.ink3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  void _openAddressesSheet(BuildContext context) {
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Direcciones',
              style: t.style(23, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 4),
            Text(
              'Para recojos, paseos y pedidos.',
              style: t.style(14.5, FontWeight.w400, t.ink2),
            ),
            const SizedBox(height: 16),
            for (final (idx, a) in DemoData.addresses.indexed)
              HuCard(
                margin: const EdgeInsets.only(bottom: 10),
                selected: a.isDefault,
                child: Row(
                  children: [
                    IconBox(
                      icon: idx == 0 ? 'i-house' : 'i-store',
                      accent: HuAccent.coral,
                      size: 42,
                      radius: 14,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.name,
                            style: t.style(15.5, FontWeight.w600, t.ink),
                          ),
                          Text(
                            a.address,
                            style: t.style(13, FontWeight.w600, t.ink2),
                          ),
                        ],
                      ),
                    ),
                    if (a.isDefault) const StatusTag('Principal'),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            HuButton(
              label: 'Agregar dirección',
              icon: 'i-plus',
              variant: HuButtonVariant.soft,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  void _openPaymentMethodsSheet(BuildContext context) {
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Métodos de pago',
              style: t.style(23, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 14),
            HuCard(
              margin: const EdgeInsets.only(bottom: 16),
              selected: true,
              child: Row(
                children: [
                  const IconBox(
                    icon: 'i-card',
                    accent: HuAccent.lav,
                    size: 42,
                    radius: 14,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visa •••• 4242',
                          style: t.style(15.5, FontWeight.w600, t.ink),
                        ),
                        Text(
                          'Vence 08/28',
                          style: t.style(13, FontWeight.w600, t.ink2),
                        ),
                      ],
                    ),
                  ),
                  const StatusTag('Principal'),
                ],
              ),
            ),
            HuButton(
              label: 'Agregar tarjeta',
              icon: 'i-plus',
              variant: HuButtonVariant.soft,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  void _openSimulationSheet(BuildContext context) {
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        final session = ctx.watch<SessionBloc>().state;
        final conn = ctx.watch<ConnectivityCubit>().state;
        final walkState = ctx.watch<LiveWalkBloc>().state;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Simular estados',
              style: t.style(23, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 4),
            Text(
              'Igual que el panel lateral del prototipo HTML.',
              style: t.style(14.5, FontWeight.w400, t.ink2),
            ),
            const SizedBox(height: 16),
            ToggleRow(
              icon: 'i-user',
              accent: HuAccent.teal,
              title: 'Cuenta nueva sin mascotas',
              subtitle: 'Vacía mascotas, citas y recordatorios',
              value: session.simNewAccount,
              onChanged: (next) {
                context
                    .read<SessionBloc>()
                    .add(SessionSimNewAccountSet(next));
                context.read<PetsBloc>().add(PetsReset(empty: next));
                context
                    .read<AppointmentsBloc>()
                    .add(AppointmentsReset(empty: next));
                context.read<RemindersBloc>().add(RemindersReset(empty: next));
                context.read<ChatBloc>().add(ChatReset(empty: next));
                context.read<NotificationsCubit>().reset(empty: next);
                if (next) {
                  context.read<LiveWalkBloc>().add(const LiveWalkCleared());
                }
                getIt<Toaster>().show(
                  next
                      ? 'Ahora ves una cuenta nueva, sin mascotas.'
                      : 'Volviste a la cuenta de Michael.',
                );
              },
            ),
            ToggleRow(
              icon: 'i-walk',
              accent: HuAccent.coral,
              title: 'Paseo en vivo activo',
              subtitle: 'Muestra el banner de Milo paseando en Inicio',
              value: walkState.walk != null,
              onChanged: (next) {
                if (next) {
                  context.read<LiveWalkBloc>().add(const LiveWalkStarted());
                } else {
                  context.read<LiveWalkBloc>().add(const LiveWalkCleared());
                }
              },
            ),
            ToggleRow(
              icon: 'i-wifi',
              accent: HuAccent.bad,
              title: 'Sin conexión',
              subtitle: 'Muestra la pantalla OfflineView',
              value: !conn.online,
              onChanged: (offline) {
                Navigator.of(ctx).pop();
                context.read<ConnectivityCubit>().setOnline(!offline);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final session = context.watch<SessionBloc>().state;
    final petsCount = context.watch<PetsBloc>().state.pets.length;
    final ordersCount = context.watch<CartBloc>().state.orders.length;
    final remsCount = context.watch<RemindersBloc>().state.pendingCount;

    return HuScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, HuLayout.top(context, 52), 0, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Perfil', style: t.h1Large),
                  HuButton(
                    label: 'Simular',
                    variant: HuButtonVariant.link,
                    onPressed: () => _openSimulationSheet(context),
                  ),
                ],
              ),
            ),

            // Cabecera de usuario .prh
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                children: [
                  HuPersonAvatar(
                    session.user.avatarKey,
                    size: 76,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.user.name,
                          style: t.style(24, FontWeight.w600, t.ink, 1.1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.user.mail,
                          style: t.style(13.5, FontWeight.w600, t.ink2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Grupo 1: Mis mascotas, Mis pedidos, Recordatorios
            _ProfileCardGroup(
              children: [
                _ProfileRow(
                  icon: 'i-paw',
                  accent: HuAccent.teal,
                  title: 'Mis mascotas',
                  value: '$petsCount',
                  onTap: () => context.go('/pets'),
                ),
                _ProfileRow(
                  icon: 'i-bag',
                  accent: HuAccent.sun,
                  title: 'Mis pedidos',
                  value: '$ordersCount',
                  onTap: () => _openOrdersSheet(context),
                ),
                _ProfileRow(
                  icon: 'i-bell',
                  accent: HuAccent.lav,
                  title: 'Recordatorios',
                  value: '$remsCount',
                  isLast: true,
                  onTap: () => context.push('/reminders'),
                ),
              ],
            ),

            // Grupo 2: Direcciones, Métodos de pago
            _ProfileCardGroup(
              children: [
                _ProfileRow(
                  icon: 'i-house',
                  accent: HuAccent.coral,
                  title: 'Direcciones',
                  subtitle: DemoData.addresses.first.address,
                  onTap: () => _openAddressesSheet(context),
                ),
                _ProfileRow(
                  icon: 'i-card',
                  accent: HuAccent.sky,
                  title: 'Métodos de pago',
                  value: 'Visa •••• 4242',
                  isLast: true,
                  onTap: () => _openPaymentMethodsSheet(context),
                ),
              ],
            ),

            // Grupo 3: Interruptores de avisos
            _ProfileCardGroup(
              children: [
                ToggleRow(boxed: false, 
                  icon: 'i-bell',
                  accent: HuAccent.lav,
                  title: 'Avisos de citas y vacunas',
                  subtitle: 'Un día antes y el mismo día',
                  value: session.prefReminders,
                  onChanged: (_) => context
                      .read<SessionBloc>()
                      .add(const SessionPreferenceToggled('rem')),
                ),
                ToggleRow(boxed: false, 
                  icon: 'i-chat',
                  accent: HuAccent.teal,
                  title: 'Mensajes',
                  subtitle: 'De tu vet y paseadores',
                  value: session.prefChat,
                  onChanged: (_) => context
                      .read<SessionBloc>()
                      .add(const SessionPreferenceToggled('chat')),
                ),
                ToggleRow(boxed: false, 
                  icon: 'i-gift',
                  accent: HuAccent.sun,
                  title: 'Promociones',
                  subtitle: 'Ofertas de la tienda',
                  value: session.prefPromo,
                  isLast: true,
                  onChanged: (_) => context
                      .read<SessionBloc>()
                      .add(const SessionPreferenceToggled('promo')),
                ),
              ],
            ),

            // Grupo 4: Emergencias, Ayuda, Cerrar sesión
            _ProfileCardGroup(
              children: [
                _ProfileRow(
                  icon: 'i-alert',
                  accent: HuAccent.bad,
                  title: 'Emergencias',
                  subtitle: 'Clínicas 24 horas cercanas',
                  onTap: () => context.push('/sos'),
                ),
                _ProfileRow(
                  icon: 'i-help',
                  accent: HuAccent.teal,
                  title: 'Ayuda',
                  onTap: () =>
                      getIt<Toaster>().show('Abriendo el centro de ayuda.'),
                ),
                _ProfileRow(
                  icon: 'i-logout',
                  accent: HuAccent.bad,
                  title: 'Cerrar sesión',
                  isDanger: true,
                  hideChevron: true,
                  isLast: true,
                  onTap: () {
                    context.read<SessionBloc>().add(const SessionLoggedOut());
                    context.go('/login');
                    getIt<Toaster>().show('Cerraste sesión.');
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),
            Center(
              child: Text(
                'Huellitas · versión 1.0',
                style: t.style(12, FontWeight.w700, t.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCardGroup extends StatelessWidget {
  const _ProfileCardGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 16, 22, 0),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
        boxShadow: HuTokens.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    this.value,
    this.isDanger = false,
    this.hideChevron = false,
    this.isLast = false,
    required this.onTap,
  });

  final String icon;
  final HuAccent accent;
  final String title;
  final String? subtitle;
  final String? value;
  final bool isDanger;
  final bool hideChevron;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            IconBox(
              icon: icon,
              accent: accent,
              size: 38,
              radius: 12,
              iconSize: 19,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.style(
                      15,
                      FontWeight.w500,
                      isDanger ? t.bad : t.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: t.style(12.5, FontWeight.w600, t.ink2),
                    ),
                ],
              ),
            ),
            if (value != null) ...[
              Text(value!, style: t.style(13.5, FontWeight.w500, t.ink2)),
              const SizedBox(width: 8),
            ],
            if (!hideChevron) HuIcon('i-chev', size: 20, color: t.ink3),
          ],
        ),
      ),
    );
  }
}
