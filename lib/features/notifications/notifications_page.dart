import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../chat/chat_bloc.dart';
import 'notifications_cubit.dart';

/// Pantalla 22: Notificaciones (`s-notif`).
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final notifs = context.watch<NotificationsCubit>().state.items;

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Notificaciones',
        onBack: () => context.pop(),
        trailing: HuHeaderCircleButton(
          icon: 'i-check',
          label: 'Marcar todo como leído',
          ghost: true,
          onTap: () {
            context.read<NotificationsCubit>().markAllRead();
            getIt<Toaster>().show('Marcaste todo como leído.');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 50),
        child: notifs.isEmpty
            ? const Center(
                child: EmptyState(
                  artKey: 'a-dog',
                  title: 'Todo al día',
                  subtitle: 'Aquí verás tus recordatorios y novedades.',
                ),
              )
            : Column(
                children: [
                  for (final n in notifs)
                    HuCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        context.read<NotificationsCubit>().markRead(n.id);
                        switch (n.targetKind) {
                          case 'appt':
                            if (n.targetId != null) {
                              context
                                  .read<AppointmentsBloc>()
                                  .add(AppointmentSelected(n.targetId!));
                            }
                            context.push('/appt');
                          case 'chat':
                            if (n.targetId != null) {
                              context
                                  .read<ChatBloc>()
                                  .add(ChatThreadOpened(n.targetId!));
                            }
                            context.push('/chat');
                          case 'rem':
                            context.push('/reminders');
                          case 'shop':
                            context.push('/shop');
                          case 'walk':
                            context.push('/walk');
                        }
                      },
                      child: Stack(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconBox(
                                icon: n.icon,
                                accent: n.accent,
                                size: 44,
                                radius: 14,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: t.style(
                                          14.5,
                                          FontWeight.w600,
                                          t.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n.subtitle,
                                        style: t.style(
                                          13,
                                          FontWeight.w600,
                                          t.ink2,
                                          1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        n.whenLabel,
                                        style: t.style(
                                          12,
                                          FontWeight.w500,
                                          t.ink3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (n.unread)
                            Positioned(
                              top: 4,
                              right: 2,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: t.coral,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

