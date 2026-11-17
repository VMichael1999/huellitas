import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/illustrated_map.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../chat/chat_bloc.dart';
import '../notifications/notifications_cubit.dart';
import '../pets/pets_bloc.dart';
import '../services/service_booking_bloc.dart';
import 'live_walk_bloc.dart';

/// Pantalla 18: Paseo en vivo (`s-walk`).
class LiveWalkPage extends StatefulWidget {
  const LiveWalkPage({super.key, this.enableTicker = true});
  final bool enableTicker;

  @override
  State<LiveWalkPage> createState() => _LiveWalkPageState();
}

class _LiveWalkPageState extends State<LiveWalkPage> {
  late LiveWalkBloc _walkBloc;

  @override
  void initState() {
    super.initState();
    _walkBloc = context.read<LiveWalkBloc>();
    final pets = context.read<PetsBloc>().state.pets;
    if (_walkBloc.state.walk == null && pets.isNotEmpty) {
      _walkBloc.add(LiveWalkStarted(petId: pets.first.id));
    }
    if (widget.enableTicker) {
      _walkBloc.add(const LiveWalkTickerStarted());
    }
  }

  @override
  void dispose() {
    if (widget.enableTicker) {
      _walkBloc.add(const LiveWalkTickerStopped());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final petsState = context.watch<PetsBloc>().state;
    final apptsState = context.watch<AppointmentsBloc>().state;

    return BlocConsumer<LiveWalkBloc, LiveWalkBlocState>(
      listenWhen: (a, b) => a.justCompletedTick != b.justCompletedTick,
      listener: (context, state) {
        final w = state.walk;
        if (w == null) return;
        final pet = petsState.byId(w.petId);
        final walker = DemoData.walkerById(w.walkerId);
        if (pet != null) {
          context.read<NotificationsCubit>().addNotification(
                AppNotification(
                  id: DateTime.now().millisecondsSinceEpoch,
                  icon: 'i-walk',
                  accent: HuAccent.coral,
                  title: '${pet.name} volvió de su paseo',
                  subtitle:
                      '${(w.seconds / 60).round()} min y 2.4 km con ${walker.firstName}.',
                  whenLabel: 'Ahora',
                  unread: true,
                  targetKind: 'walk',
                ),
              );
          getIt<Toaster>().show('${pet.name} ya está de vuelta en casa.');
        }
      },
      builder: (context, state) {
        final w = state.walk;
        final pet = w != null ? petsState.byId(w.petId) : petsState.pets.firstOrNull;
        if (w == null || pet == null) {
          return HuScaffold(
            topBar: HuTopBar(title: 'Paseo', onBack: () => context.go('/home')),
            body: const Center(
              child: EmptyState(
                artKey: 'a-walk',
                title: 'Reserva un paseo',
                subtitle: 'Reserva un paseo para verlo en vivo.',
              ),
            ),
          );
        }

        final walker = DemoData.walkerById(w.walkerId);
        final mm = w.seconds ~/ 60;
        final ss = w.seconds % 60;
        final km = (2.4 * w.progress).toStringAsFixed(1);
        final isLive = w.state == LiveWalkState.live;

        return HuScaffold(
          showVeil: false,
          topBar: HuTopBar(
            title: 'Paseo de ${pet.name}',
            subtitle: isLive ? 'En vivo' : 'Terminado',
            clear: true,
            onBack: () => context.pop(),
            trailing: HuHeaderCircleButton(
              icon: 'i-alert',
              label: 'Emergencia',
              iconColor: t.bad,
              onTap: () => context.push('/sos'),
            ),
          ),
          body: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 600,
                child: IllustratedMap(
                  height: 600,
                  borderRadius: 0,
                  walkProgress: w.progress,
                  petArtKey: pet.artKey,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 30,
                child: HuCard(
                  radius: 22,
                  padding: const EdgeInsets.all(18),
                  child: isLive
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                HuPersonAvatar(
                                  walker.avatarKey,
                                  size: 52,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        walker.name,
                                        style: t.style(
                                          16,
                                          FontWeight.w600,
                                          t.ink,
                                        ),
                                      ),
                                      Text(
                                        '★ ${walker.rating} · paseando a ${pet.name}',
                                        style: t.style(
                                          13,
                                          FontWeight.w500,
                                          t.ink2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 26,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.badSoft,
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: t.bad,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'En vivo',
                                        style: t.style(
                                          12,
                                          FontWeight.w600,
                                          t.bad,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _WalkStatTile(
                                    value:
                                        '${HuFormat.pad2(mm)}:${HuFormat.pad2(ss)}',
                                    label: 'Tiempo',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _WalkStatTile(
                                    value: '$km km',
                                    label: 'Distancia',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _WalkStatTile(
                                    value: '${w.events.length}',
                                    label: 'Paradas',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final ev in w.events)
                                  StatusTag(
                                    '${ev.text} · ${HuFormat.ampm(ev.time)}',
                                    icon: ev.icon,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: HuButton(
                                    label: 'Llamar',
                                    icon: 'i-phone',
                                    variant: HuButtonVariant.soft,
                                    small: true,
                                    onPressed: () => getIt<Toaster>().show(
                                      'Llamando a ${walker.firstName}…',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: HuButton(
                                    label: 'Mensaje',
                                    icon: 'i-chat',
                                    small: true,
                                    onPressed: () {
                                      context
                                          .read<ChatBloc>()
                                          .add(ChatThreadOpened(walker.id));
                                      context.push('/chat');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                PetAvatar(
                                  artKey: pet.artKey,
                                  accent: HuAccent.teal,
                                  size: 64,
                                  radius: 18,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '¡${pet.name} volvió feliz!',
                                        style: t.style(
                                          16,
                                          FontWeight.w600,
                                          t.ink,
                                        ),
                                      ),
                                      Text(
                                        '$mm min · 2.4 km · ${w.events.length} paradas',
                                        style: t.style(
                                          13,
                                          FontWeight.w500,
                                          t.ink2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const StatusTag('Terminado',
                                    accent: HuAccent.ok),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '¿Cómo estuvo el paseo con ${walker.firstName}?',
                              style: t.style(14, FontWeight.w700, t.ink),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                for (int k = 1; k <= 5; k++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: HuPressable(
                                      onTap: () {
                                        context
                                            .read<LiveWalkBloc>()
                                            .add(LiveWalkRated(k));
                                        getIt<Toaster>().show(
                                          'Gracias por calificar el paseo.',
                                        );
                                      },
                                      semanticLabel: '$k de 5',
                                      child: HuIcon(
                                        'i-star',
                                        size: 34,
                                        color: w.rating >= k
                                            ? t.sun
                                            : const Color(0xFFDCE6E3),
                                        fill: w.rating >= k
                                            ? t.sun
                                            : const Color(0xFFDCE6E3),
                                        strokeWidth: 0,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: HuButton(
                                    label: 'Ver fotos',
                                    icon: 'i-camera',
                                    variant: HuButtonVariant.soft,
                                    small: true,
                                    onPressed: () => getIt<Toaster>().show(
                                      'Diego compartió 3 fotos del paseo.',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: HuButton(
                                    label: 'Repetir paseo',
                                    icon: 'i-repeat',
                                    small: true,
                                    onPressed: () {
                                      context
                                          .read<ServiceBookingBloc>()
                                          .add(ServiceBookingOpened(
                                            serviceId: 'walk',
                                            pet: pet,
                                            appointments:
                                                apptsState.appointments,
                                          ));
                                      context.push('/service/book');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalkStatTile extends StatelessWidget {
  const _WalkStatTile({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: t.style(22, FontWeight.w600, t.ink)),
          Text(label, style: t.style(12, FontWeight.w500, t.ink2)),
        ],
      ),
    );
  }
}
