import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/domain/rules.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../auth/session_bloc.dart';
import '../booking/booking_bloc.dart';
import '../notifications/notifications_cubit.dart';
import '../pets/pet_pages.dart';
import '../pets/pet_wizard_bloc.dart';
import '../pets/pets_bloc.dart';
import '../services/service_booking_bloc.dart';
import '../walk/live_walk_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openPetNew(BuildContext context, bool isFirst) {
    context.read<PetWizardBloc>().add(PetWizardStarted(isFirstPet: isFirst));
    context.push('/pet/new');
  }

  void _openBook(BuildContext context, {String? petId, String? typeId}) {
    final pets = context.read<PetsBloc>().state.pets;
    if (pets.isEmpty) {
      getIt<Toaster>().show('Primero agrega a tu mascota.');
      _openPetNew(context, true);
      return;
    }
    final appts = context.read<AppointmentsBloc>().state.appointments;
    context.read<BookingBloc>().add(BookingStarted(
          pets: pets,
          appointments: appts,
          petId: petId,
          typeId: typeId,
        ));
    context.push('/book');
  }

  void _openPetMenu(BuildContext context, Pet pet, DateTime today) {
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pet.name, style: t.style(23, FontWeight.w600, t.ink, 1.15)),
            const SizedBox(height: 4),
            Text(
              '${pet.breed} • ${HuFormat.ageOf(today, pet.birthDate)}',
              style: t.style(14.5, FontWeight.w400, t.ink2),
            ),
            const SizedBox(height: 8),
            _MenuOption(
              icon: 'i-paw',
              label: 'Ver ficha',
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<PetsBloc>().add(PetSelected(pet.id, tab: 'vax'));
                context.push('/pet');
              },
            ),
            _MenuOption(
              icon: 'i-pulse',
              label: 'Registrar cómo está hoy',
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<PetsBloc>().add(PetSelected(pet.id, tab: 'vax'));
                context.push('/pet');
                Future<void>.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    openPetDailyLogSheet(context, pet);
                  }
                });
              },
            ),
            _MenuOption(
              icon: 'i-cal',
              label: 'Reservar cita',
              onTap: () {
                Navigator.of(ctx).pop();
                _openBook(context, petId: pet.id);
              },
            ),
            _MenuOption(
              icon: 'i-scissors',
              label: 'Reservar grooming',
              isLast: true,
              onTap: () {
                Navigator.of(ctx).pop();
                final appts = context.read<AppointmentsBloc>().state.appointments;
                context.read<ServiceBookingBloc>().add(ServiceBookingOpened(
                      serviceId: 'groom',
                      pet: pet,
                      appointments: appts,
                    ));
                context.push('/service/book');
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
    final clock = getIt<Clock>();
    final today = clock.today;
    final session = context.watch<SessionBloc>().state;
    final petsState = context.watch<PetsBloc>().state;
    final apptsState = context.watch<AppointmentsBloc>().state;
    final notifState = context.watch<NotificationsCubit>().state;
    final walkState = context.watch<LiveWalkBloc>().state;

    final pets = petsState.pets;
    final upcoming = apptsState.upcoming(today);
    final soonVax = DemoData.nextDueVaccine(today, pets);
    final liveWalk = walkState.walk;
    final hasLiveWalk = liveWalk != null &&
        liveWalk.state == LiveWalkState.live &&
        petsState.byId(liveWalk.petId) != null;

    return HuScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera .hh2
            Padding(
              padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 66), 22, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Hola, ${session.user.firstName}! 👋',
                          style: t.style(15, FontWeight.w400, t.ink),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 270),
                          child: Text(
                            '¿Cómo cuidamos hoy a tu mascota?',
                            style: t.h1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Campana en círculo gris .bellb
                      HuPressable(
                        onTap: () => context.push('/notifications'),
                        semanticLabel: 'Notificaciones',
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: t.chip,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: HuIcon('i-bell', size: 21, color: t.ink),
                              ),
                              if (notifState.hasUnread)
                                Positioned(
                                  top: 8,
                                  right: 9,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: t.coral,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Avatar del usuario .meav
                      HuPressable(
                        onTap: () => context.go('/profile'),
                        semanticLabel: 'Tu perfil',
                        child: Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x661D2A44),
                                offset: Offset(0, 6),
                                blurRadius: 16,
                                spreadRadius: -6,
                              ),
                            ],
                          ),
                          child: HuPersonAvatar(
                            session.user.avatarKey,
                            size: 48,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mis mascotas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: HuSectionHeader(
                'Mis mascotas',
                actionLabel: pets.isNotEmpty ? 'Ver todas' : null,
                onAction: pets.isNotEmpty ? () => context.go('/pets') : null,
              ),
            ),

            SizedBox(
              height: 286,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 14),
                children: [
                  for (final p in pets) ...[
                    Builder(
                      builder: (_) {
                        final score = PetHealthRules.healthScore(today, p);
                        final (hl, _) = PetHealthRules.healthTag(score);
                        return PetCard(
                          name: p.name,
                          breedAndAge:
                              '${p.breed} • ${HuFormat.ageOf(today, p.birthDate)}',
                          artKey: p.artKey,
                          accent: p.accent,
                          healthLabel: hl,
                          onTap: () {
                            context
                                .read<PetsBloc>()
                                .add(PetSelected(p.id, tab: 'vax'));
                            context.push('/pet');
                          },
                          onMenuTap: () => _openPetMenu(context, p, today),
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                  ],
                  AddPetCard(
                    label: pets.isNotEmpty
                        ? 'Agregar mascota'
                        : 'Agrega a tu primera mascota',
                    onTap: () => _openPetNew(context, pets.isEmpty),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de paseo en vivo si está activo
                  if (hasLiveWalk)
                    Builder(
                      builder: (_) {
                        final walkPet = petsState.byId(liveWalk.petId)!;
                        final walker = DemoData.walkerById(liveWalk.walkerId);
                        return VaccineBanner(
                          isLiveWalk: true,
                          title: '${walkPet.name} está paseando',
                          subtitle:
                              'Con ${walker.firstName} · toca para ver el mapa',
                          onTap: () => context.push('/walk'),
                        );
                      },
                    ),

                  // Accesos rápidos (3x2)
                  const HuSectionHeader('Accesos rápidos'),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 118 / 112,
                    children: [
                      QuickAction(
                        dqIcon: 'cal',
                        iconColor: t.teal,
                        label: 'Reservar\ncita',
                        onTap: () => _openBook(context),
                      ),
                      QuickAction(
                        dqIcon: 'steth',
                        iconColor: t.teal,
                        label: 'Buscar\nveterinario',
                        onTap: () => context.push('/vets'),
                      ),
                      QuickAction(
                        dqIcon: 'folder',
                        iconColor: t.teal,
                        label: 'Historial\nmédico',
                        onTap: () {
                          if (pets.isEmpty) {
                            getIt<Toaster>().show('Primero agrega a tu mascota.');
                            _openPetNew(context, true);
                            return;
                          }
                          context
                              .read<PetsBloc>()
                              .add(PetSelected(pets.first.id, tab: 'vax'));
                          context.push('/pet');
                        },
                      ),
                      QuickAction(
                        dqIcon: 'scissors',
                        iconColor: t.coral,
                        label: 'Grooming',
                        onTap: () => context.push('/services'),
                      ),
                      QuickAction(
                        dqIcon: 'bell',
                        iconColor: t.lav,
                        label: 'Recordatorios',
                        onTap: () => context.push('/reminders'),
                      ),
                      QuickAction(
                        dqIcon: 'bag',
                        iconColor: t.teal,
                        label: 'Tienda',
                        onTap: () => context.push('/shop'),
                      ),
                    ],
                  ),

                  // Próximas tareas
                  HuSectionHeader(
                    'Próximas tareas',
                    actionLabel: upcoming.isNotEmpty ? 'Ver todas' : null,
                    onAction:
                        upcoming.isNotEmpty ? () => context.go('/appts') : null,
                  ),

                  if (upcoming.isNotEmpty)
                    for (final (idx, a) in upcoming.take(3).indexed)
                      Builder(
                        builder: (_) {
                          final pet = petsState.byId(a.petId);
                          if (pet == null) return const SizedBox.shrink();
                          return TaskRow(
                            isoDate: a.date,
                            title: DemoData.appointmentTitle(a),
                            subtitle: '${pet.name} • ${HuFormat.ampm(a.time)}',
                            petArtKey: pet.artKey,
                            useTealStrip: idx.isOdd,
                            onTap: () {
                              context
                                  .read<AppointmentsBloc>()
                                  .add(AppointmentSelected(a.id));
                              context.push('/appt');
                            },
                          );
                        },
                      )
                  else
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 84),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: t.border),
                        boxShadow: HuTokens.cardShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No tienes citas próximas.',
                            style: t.style(15, FontWeight.w400, t.ink2),
                          ),
                          HuButton(
                            label: 'Reservar una cita',
                            variant: HuButtonVariant.link,
                            onPressed: () => _openBook(context),
                          ),
                        ],
                      ),
                    ),

                  // VaccineBanner al final
                  if (soonVax != null)
                    Builder(
                      builder: (_) {
                        final vState = PetHealthRules.vaccineState(
                          today,
                          soonVax.vaccine,
                        );
                        final relText = HuFormat.rel(today, soonVax.vaccine.nextDue);
                        final sub =
                            '${soonVax.vaccine.name} · ${vState == VaccineState.late ? 'vencida $relText' : 'le toca $relText'}';
                        return VaccineBanner(
                          title: 'Hora de vacunar a ${soonVax.pet.name}',
                          subtitle: sub,
                          onTap: () => _openBook(
                            context,
                            petId: soonVax.pet.id,
                            typeId: 'vac',
                          ),
                        );
                      },
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

class _MenuOption extends StatelessWidget {
  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: t.line, width: 1)),
        ),
        child: Row(
          children: [
            HuIcon(icon, size: 22, color: t.teal),
            const SizedBox(width: 14),
            Text(label, style: t.style(15, FontWeight.w500, t.ink)),
          ],
        ),
      ),
    );
  }
}
