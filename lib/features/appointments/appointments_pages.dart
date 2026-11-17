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
import '../../core/widgets/google_map_view.dart';
import '../../core/widgets/toaster.dart';
import '../booking/booking_bloc.dart';
import '../chat/chat_bloc.dart';
import '../pets/pet_wizard_bloc.dart';
import '../pets/pets_bloc.dart';
import '../services/service_booking_bloc.dart';
import '../walk/live_walk_bloc.dart';
import 'appointments_bloc.dart';

/// Pantalla 11: Mis citas (`s-appts`, «Upcoming Appointment»).
class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  void _openBook(
    BuildContext context, {
    String? petId,
    String? typeId,
    String? vetId,
  }) {
    final pets = context.read<PetsBloc>().state.pets;
    if (pets.isEmpty) {
      context
          .read<PetWizardBloc>()
          .add(const PetWizardStarted(isFirstPet: true));
      context.push('/pet/new');
      return;
    }
    final appts = context.read<AppointmentsBloc>().state.appointments;
    context.read<BookingBloc>().add(BookingStarted(
          pets: pets,
          appointments: appts,
          petId: petId,
          typeId: typeId,
          vetId: vetId,
        ));
    context.push('/book');
  }

  void _repeatAppointment(BuildContext context, Appointment a) {
    if (a.kind == AppointmentKind.vet) {
      _openBook(
        context,
        petId: a.petId,
        typeId: a.typeId,
        vetId: a.vetId,
      );
    } else {
      final petsState = context.read<PetsBloc>().state;
      final pet = petsState.byId(a.petId) ?? petsState.pets.firstOrNull;
      if (pet == null) return;
      context.read<ServiceBookingBloc>().add(ServiceBookingOpened(
            serviceId: a.serviceId ?? 'groom',
            pet: pet,
            appointments: context.read<AppointmentsBloc>().state.appointments,
          ));
      context.push('/service/book');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final petsState = context.watch<PetsBloc>().state;
    final apptsState = context.watch<AppointmentsBloc>().state;

    final pets = petsState.pets;
    final upcoming = apptsState.upcoming(today);
    final past = apptsState.past(today);
    final nextHero = upcoming
            .where((x) => x.kind == AppointmentKind.vet)
            .firstOrNull ??
        upcoming.firstOrNull;
    final soonVax = DemoData.nextDueVaccine(today, pets);
    final list = apptsState.segment == 'up' ? upcoming : past;

    return HuScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, HuLayout.top(context, 62), 0, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Próxima\ncita + botón calendario tealSoft
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Próxima\ncita', style: t.h1),
                  HuHeaderCircleButton(
                    icon: 'i-calp',
                    label: 'Reservar cita',
                    tealSoft: true,
                    onTap: () => _openBook(context),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta azul clara de próxima cita (.nxt)
                  if (nextHero != null)
                    Builder(
                      builder: (_) {
                        final d = HuFormat.fromIso(nextHero.date);
                        final dl = HuFormat.daysFrom(today, nextHero.date);
                        final dayPrefix = dl == 0
                            ? 'Hoy'
                            : dl == 1
                                ? 'Mañana'
                                : HuFormat.cap(HuFormat.dow[HuFormat.jsDay(d)]);
                        final dateStr =
                            '$dayPrefix, ${d.day} ${HuFormat.mon[d.month - 1]}';
                        final vet = nextHero.kind == AppointmentKind.vet &&
                                nextHero.vetId != null
                            ? DemoData.vetById(nextHero.vetId!)
                            : null;
                        final pet = petsState.byId(nextHero.petId) ??
                            pets.firstOrNull;

                        return HuPressable(
                          onTap: () {
                            context
                                .read<AppointmentsBloc>()
                                .add(AppointmentSelected(nextHero.id));
                            context.push('/appt');
                          },
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 188),
                            padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFEEF5FC), Color(0xFFE3EFFA)],
                              ),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 18),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateStr,
                                          style: t.style(
                                            16,
                                            FontWeight.w500,
                                            t.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              width: 9,
                                              height: 9,
                                              decoration: BoxDecoration(
                                                color: t.sun,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              HuFormat.ampm(nextHero.time),
                                              style: t.style(
                                                13.5,
                                                FontWeight.w400,
                                                t.ink,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          DemoData.appointmentTitle(nextHero),
                                          style: t.style(
                                            17,
                                            FontWeight.w600,
                                            t.ink,
                                            1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _NextCardInfoLine(
                                          icon: 'i-user',
                                          text: vet != null
                                              ? vet.name
                                              : DemoData.appointmentWho(
                                                  nextHero,
                                                ),
                                        ),
                                        const SizedBox(height: 6),
                                        _NextCardInfoLine(
                                          icon: 'i-pin',
                                          text: DemoData.appointmentPlace(
                                            nextHero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (vet != null && pet != null)
                                  SizedBox(
                                    width: 150,
                                    height: 168,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned.fill(
                                          child: HuPersonAvatar(
                                            vet.avatarKey,
                                            size: 150,
                                            height: 168,
                                            alignment: Alignment.topCenter,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(22),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: -14,
                                          bottom: -4,
                                          width: 76,
                                          height: 76,
                                          child: HuArt(
                                            pet.artKey,
                                            width: 76,
                                            height: 76,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (pet != null)
                                  SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: HuArt(
                                      pet.artKey,
                                      width: 140,
                                      height: 140,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Resumen de salud / Ver todo (.hpets)
                  HuSectionHeader(
                    'Resumen de salud',
                    actionLabel: 'Ver todo',
                    onAction: () => context.go('/pets'),
                  ),
                  if (pets.isNotEmpty)
                    Row(
                      children: [
                        for (final (idx, p) in pets.take(2).indexed) ...[
                          if (idx > 0) const SizedBox(width: 12),
                          Expanded(
                            child: Builder(
                              builder: (_) {
                                final hh = PetHealthRules.healthScore(today, p);
                                final (hl, hc) = PetHealthRules.healthTag(hh);
                                final vetHist = p.history
                                    .where((x) => x.vetId != null)
                                    .toList()
                                  ..sort((a, b) => b.date.compareTo(a.date));
                                final lastControl = vetHist.isNotEmpty
                                    ? HuFormat.fDate(vetHist.first.date)
                                    : 'Sin registro';
                                return HuCard(
                                  radius: 20,
                                  padding: const EdgeInsets.all(14),
                                  onTap: () {
                                    context
                                        .read<PetsBloc>()
                                        .add(PetSelected(p.id, tab: 'vax'));
                                    context.push('/pet');
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color:
                                                  p.accent.petSummaryCircleBg,
                                              shape: BoxShape.circle,
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: HuArt(
                                              p.artKey,
                                              width: 52,
                                              height: 52,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.name,
                                                  style: t.style(
                                                    16,
                                                    FontWeight.w600,
                                                    t.ink,
                                                    1.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  hl == 'Saludable'
                                                      ? 'Buena salud'
                                                      : hl,
                                                  style: t.style(
                                                    13,
                                                    FontWeight.w500,
                                                    hc == HuAccent.ok
                                                        ? t.teal
                                                        : hc == HuAccent.sun
                                                            ? const Color(
                                                                0xFFB7790F)
                                                            : t.bad,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Último control\n$lastControl',
                                              style: t.style(
                                                12,
                                                FontWeight.w400,
                                                t.ink2,
                                                1.4,
                                              ),
                                            ),
                                          ),
                                          HealthRing(
                                            score: hh,
                                            size: 50,
                                            strokeWidth: 4.5,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),

                  // VaccineBanner
                  if (soonVax != null)
                    VaccineBanner(
                      title: 'Hora de vacunar a ${soonVax.pet.name}',
                      subtitle: 'Toca para ver las próximas vacunas',
                      onTap: () {
                        context
                            .read<PetsBloc>()
                            .add(PetSelected(soonVax.pet.id, tab: 'vax'));
                        context.push('/pet');
                      },
                    ),

                  const HuSectionHeader('Mis citas', bottomMargin: 12),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SegmentedTabs<String>(
                items: const [
                  ('up', 'Próximas'),
                  ('past', 'Pasadas'),
                ],
                selected: apptsState.segment,
                onChanged: (seg) => context
                    .read<AppointmentsBloc>()
                    .add(AppointmentsSegmentChanged(seg)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: apptsState.loadingSkeleton
                  ? const Column(
                      children: [
                        HuSkeleton(height: 104),
                        SizedBox(height: 12),
                        HuSkeleton(height: 104),
                        SizedBox(height: 12),
                        HuSkeleton(height: 104),
                      ],
                    )
                  : list.isEmpty
                      ? apptsState.segment == 'up'
                          ? EmptyState(
                              artKey: 'a-vet',
                              title: 'Sin citas próximas',
                              subtitle:
                                  'Reserva un chequeo o un baño para tu mascota.',
                              buttonLabel: 'Reservar cita',
                              onButtonPressed: () => _openBook(context),
                            )
                          : const EmptyState(
                              artKey: 'a-dog',
                              title: 'Aún no hay citas pasadas',
                              subtitle:
                                  'Aquí verás las visitas anteriores para repetirlas.',
                            )
                      : Column(
                          children: [
                            for (final a in list)
                              Builder(
                                builder: (_) {
                                  final pet = petsState.byId(a.petId);
                                  if (pet == null) {
                                    return const SizedBox.shrink();
                                  }
                                  final isUp =
                                      a.status == AppointmentStatus.confirmed &&
                                          HuFormat.daysFrom(today, a.date) >= 0;
                                  final (stLabel, stAccent) = a.status ==
                                          AppointmentStatus.cancelled
                                      ? ('Cancelada', HuAccent.bad)
                                      : isUp
                                          ? ('Confirmada', HuAccent.ok)
                                          : ('Completada', HuAccent.muted);
                                  final stripColor =
                                      a.kind == AppointmentKind.svc
                                          ? t.lav
                                          : a.status ==
                                                  AppointmentStatus.cancelled
                                              ? t.coral
                                              : t.teal;

                                  return HuCard(
                                    radius: 18,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(14),
                                    onTap: () {
                                      context
                                          .read<AppointmentsBloc>()
                                          .add(AppointmentSelected(a.id));
                                      context.push('/appt');
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        DateBox(
                                          isoDate: a.date,
                                          stripColor: stripColor,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DemoData.appointmentTitle(a),
                                                style: t.style(
                                                  15.5,
                                                  FontWeight.w600,
                                                  t.ink,
                                                  1.3,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  PetAvatar(
                                                    artKey: pet.artKey,
                                                    accent: pet.accent,
                                                    size: 20,
                                                    circular: true,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '${pet.name} · ${DemoData.appointmentWho(a)}',
                                                      style: t.style(
                                                        13,
                                                        FontWeight.w400,
                                                        t.ink2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  HuIcon(
                                                    'i-clock',
                                                    size: 14,
                                                    color: t.ink2,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '${HuFormat.ampm(a.time)} · ${DemoData.appointmentPlace(a)}',
                                                      style: t.style(
                                                        13,
                                                        FontWeight.w400,
                                                        t.ink2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (!isUp &&
                                                  a.status ==
                                                      AppointmentStatus
                                                          .done) ...[
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    _SmallActionPill(
                                                      icon: 'i-repeat',
                                                      label: 'Repetir',
                                                      bg: t.tealSoft,
                                                      fg: t.tealDeep,
                                                      onTap: () =>
                                                          _repeatAppointment(
                                                        context,
                                                        a,
                                                      ),
                                                    ),
                                                    if (a.kind ==
                                                        AppointmentKind
                                                            .vet) ...[
                                                      const SizedBox(width: 8),
                                                      _SmallActionPill(
                                                        icon: 'i-doc',
                                                        label: 'Informe',
                                                        bg: t.chip,
                                                        fg: t.ink2,
                                                        onTap: () {
                                                          context
                                                              .read<PetsBloc>()
                                                              .add(PetSelected(
                                                                a.petId,
                                                                tab: 'hist',
                                                              ));
                                                          context.push('/pet');
                                                        },
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        StatusTag(stLabel, accent: stAccent),
                                      ],
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

class _NextCardInfoLine extends StatelessWidget {
  const _NextCardInfoLine({required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: t.coral,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: HuIcon(icon, size: 12, color: Colors.white, strokeWidth: 2.4),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.style(13, FontWeight.w400, t.ink2),
          ),
        ),
      ],
    );
  }
}

class _SmallActionPill extends StatelessWidget {
  const _SmallActionPill({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final String icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HuIcon(icon, size: 15, color: fg),
            const SizedBox(width: 5),
            Text(label, style: t.style(13, FontWeight.w600, fg)),
          ],
        ),
      ),
    );
  }
}

/// Pantalla 12 y 13: Detalle de cita (`s-appt`) y hoja de cancelación.
class AppointmentDetailPage extends StatelessWidget {
  const AppointmentDetailPage({super.key});

  void _openCancelSheet(
    BuildContext context,
    Appointment a,
    Pet pet,
    bool isLate,
  ) {
    String selectedWhy = '';
    const reasons = [
      'Ya está mejor',
      'No puedo ir',
      'Encontré otra hora',
      'Otro motivo',
    ];
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Cancelar la cita?',
                  style: t.style(23, FontWeight.w600, t.ink, 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DemoData.appointmentTitle(a)} de ${pet.name}, ${HuFormat.fShort(a.date)} a las ${HuFormat.ampm(a.time)}.',
                  style: t.style(14.5, FontWeight.w400, t.ink2),
                ),
                const SizedBox(height: 12),
                HuInfoBox(
                  icon: isLate ? 'i-info' : 'i-shield',
                  accent: isLate ? HuAccent.bad : HuAccent.teal,
                  text: isLate
                      ? 'Faltan menos de 12 horas. Se cobrará un cargo de \$10.'
                      : 'Cancelación sin costo.',
                ),
                const SizedBox(height: 14),
                Text(
                  '¿Por qué? (opcional)',
                  style: t.style(13, FontWeight.w600, t.ink2),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in reasons)
                      HuChip(
                        label: r,
                        selected: selectedWhy == r,
                        onTap: () => setSheetState(
                          () => selectedWhy = selectedWhy == r ? '' : r,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                HuButton(
                  label: 'Cancelar cita',
                  variant: HuButtonVariant.danger,
                  onPressed: () {
                    context
                        .read<AppointmentsBloc>()
                        .add(AppointmentCancelled(a.id, reason: selectedWhy));
                    Navigator.of(ctx).pop();
                    getIt<Toaster>().show(
                      'Cita cancelada.',
                      actionLabel: 'Reservar otra',
                      onAction: () => _repeat(context, a),
                    );
                  },
                ),
                const SizedBox(height: 10),
                HuButton(
                  label: 'Mantener la cita',
                  variant: HuButtonVariant.line,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _repeat(BuildContext context, Appointment a) {
    final petsState = context.read<PetsBloc>().state;
    final apptsState = context.read<AppointmentsBloc>().state;
    if (a.kind == AppointmentKind.vet) {
      context.read<BookingBloc>().add(BookingStarted(
            pets: petsState.pets,
            appointments: apptsState.appointments,
            petId: a.petId,
            typeId: a.typeId,
            vetId: a.vetId,
          ));
      context.push('/book');
    } else {
      final pet = petsState.byId(a.petId) ?? petsState.pets.firstOrNull;
      if (pet == null) return;
      context.read<ServiceBookingBloc>().add(ServiceBookingOpened(
            serviceId: a.serviceId ?? 'groom',
            pet: pet,
            appointments: apptsState.appointments,
          ));
      context.push('/service/book');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final clock = getIt<Clock>();
    final today = clock.today;
    final apptsState = context.watch<AppointmentsBloc>().state;
    final petsState = context.watch<PetsBloc>().state;
    final walkState = context.watch<LiveWalkBloc>().state;

    final a = apptsState.selectedOrFirst(today);
    if (a == null) {
      return HuScaffold(
        topBar: HuTopBar(title: 'Detalle', onBack: () => context.pop()),
        body: const SizedBox.shrink(),
      );
    }
    final pet = petsState.byId(a.petId) ?? petsState.pets.first;
    final isUp = a.status == AppointmentStatus.confirmed &&
        HuFormat.daysFrom(today, a.date) >= 0;
    final isLate =
        isUp && BookingPricingRules.isWithin12Hours(clock.now(), a.date, a.time);
    final (stLabel, stAccent) = a.status == AppointmentStatus.cancelled
        ? ('Cancelada', HuAccent.bad)
        : isUp
            ? ('Confirmada', HuAccent.ok)
            : ('Completada', HuAccent.muted);
    final clinic = a.kind == AppointmentKind.vet
        ? DemoData.clinicById(a.clinicId)
        : DemoData.clinicById('c1');
    final isVideo = a.typeId == 'video';

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Detalle',
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, HuLayout.top(context, 116), 0, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera .adh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  PetAvatar(
                    artKey: pet.artKey,
                    accent: pet.accent,
                    size: 86,
                    radius: 26,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusTag(stLabel, accent: stAccent),
                        const SizedBox(height: 8),
                        Text(
                          DemoData.appointmentTitle(a),
                          style: t.style(25, FontWeight.w600, t.ink, 1.15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Para ${pet.name} · ${a.id}',
                          style: t.style(13.5, FontWeight.w700, t.ink2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumen en tarjeta .rows
                  HuCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          icon: a.kind == AppointmentKind.vet
                              ? 'i-steth'
                              : 'i-user',
                          label: a.kind == AppointmentKind.vet
                              ? 'Veterinario'
                              : 'A cargo',
                          leadingAvatarKey: a.kind == AppointmentKind.vet
                              ? DemoData.vetById(a.vetId ?? 'sofia').avatarKey
                              : a.walkerId != null
                                  ? DemoData.walkerById(a.walkerId!).avatarKey
                                  : null,
                          value: DemoData.appointmentWho(a),
                        ),
                        _DetailRow(
                          icon: 'i-cal',
                          label: 'Fecha',
                          value:
                              '${HuFormat.cap(HuFormat.fLong(a.date))}${a.endDate != null ? ' al ${HuFormat.fShort(a.endDate!)}' : ''}',
                        ),
                        _DetailRow(
                          icon: 'i-clock',
                          label: 'Hora',
                          value: HuFormat.ampm(a.time),
                        ),
                        if (a.size != null)
                          _DetailRow(
                            icon: 'i-scale',
                            label: 'Tamaño',
                            value: PetHealthRules.sizeLabels[a.size!]?.$1 ??
                                a.size!,
                          ),
                        if (a.extras.isNotEmpty)
                          _DetailRow(
                            icon: 'i-plus',
                            label: 'Extras',
                            value: a.extras
                                .map((k) => DemoData.extras[k]?.name ?? k)
                                .join(', '),
                          ),
                        _DetailRow(
                          icon: 'i-tag',
                          label: a.kind == AppointmentKind.vet
                              ? 'Consulta, pagas en la clínica'
                              : 'Total',
                          value: Money.usd(a.price),
                          isTotal: true,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  if (a.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: HuInfoBox(
                        icon: 'i-note',
                        cardStyle: true,
                        text: 'Tu nota: «${a.note}»',
                      ),
                    ),

                  if (a.serviceId == 'walk' &&
                      walkState.walk != null &&
                      walkState.walk!.appointmentId == a.id)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: HuButton(
                        label: 'Ver paseo en vivo',
                        icon: 'i-walk',
                        variant: HuButtonVariant.pay,
                        onPressed: () => context.push('/walk'),
                      ),
                    ),

                  if (isVideo) ...[
                    const SizedBox(height: 16),
                    HuButton(
                      label: 'Entrar a la videoconsulta',
                      icon: 'i-video',
                      onPressed: isUp && HuFormat.daysFrom(today, a.date) == 0
                          ? () => getIt<Toaster>()
                              .show('Conectando con la videoconsulta…')
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Se habilita 10 minutos antes de la hora.',
                        style: t.style(12.5, FontWeight.w600, t.ink3),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    GoogleMapView(
                      height: 170,
                      singlePinColor: clinic.is24h ? t.bad : t.teal,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 12, 2, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.serviceId == 'walk'
                                      ? 'Recojo en tu casa'
                                      : clinic.name,
                                  style: t.style(15, FontWeight.w700, t.ink),
                                ),
                                Text(
                                  a.serviceId == 'walk'
                                      ? DemoData.addresses.first.address
                                      : '${clinic.address} · ${clinic.km} km',
                                  style: t.style(13, FontWeight.w600, t.ink2),
                                ),
                              ],
                            ),
                          ),
                          HuButton(
                            label: 'Cómo llegar',
                            icon: 'i-map',
                            variant: HuButtonVariant.soft,
                            small: true,
                            expand: false,
                            onPressed: () => getIt<Toaster>()
                                .show('Abriendo el mapa con la ruta.'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 3 botones de acción .acts3
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionSquare(
                          icon: 'i-calp',
                          label: 'Calendario',
                          onTap: () =>
                              getIt<Toaster>().show('Añadido a tu calendario.'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionSquare(
                          icon: 'i-chat',
                          label: 'Mensaje',
                          onTap: () {
                            final chatId = a.kind == AppointmentKind.vet
                                ? (a.vetId ?? 'c1')
                                : (a.walkerId ?? 'c1');
                            context
                                .read<ChatBloc>()
                                .add(ChatThreadOpened(chatId));
                            context.push('/chat');
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionSquare(
                          icon: 'i-phone',
                          label: 'Llamar',
                          onTap: () => getIt<Toaster>().show(
                            'Llamando a ${a.kind == AppointmentKind.vet ? clinic.name : 'Huellitas Centro'}…',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  if (isUp) ...[
                    HuButton(
                      label: 'Cambiar fecha',
                      icon: 'i-cal',
                      onPressed: () {
                        if (a.serviceId == 'board') {
                          getIt<Toaster>().show(
                            'Para cambiar las fechas del hospedaje, escríbenos por el chat.',
                          );
                          return;
                        }
                        context.read<BookingBloc>().add(BookingStarted(
                              pets: petsState.pets,
                              appointments: apptsState.appointments,
                              rescheduleAppointment: a,
                            ));
                        context.push('/book');
                      },
                    ),
                    const SizedBox(height: 10),
                    HuButton(
                      label: 'Cancelar cita',
                      variant: HuButtonVariant.line,
                      customTextColor: t.bad,
                      customBorderColor: t.bad,
                      onPressed: () =>
                          _openCancelSheet(context, a, pet, isLate),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        isLate
                            ? 'Faltan menos de 12 horas: cambiar o cancelar tiene un cargo de \$10.'
                            : 'Cambia o cancela gratis hasta 12 horas antes.',
                        textAlign: TextAlign.center,
                        style: t.style(
                          12.5,
                          FontWeight.w600,
                          isLate ? t.bad : t.ink3,
                        ),
                      ),
                    ),
                  ] else if (a.status == AppointmentStatus.done) ...[
                    HuButton(
                      label: 'Repetir',
                      icon: 'i-repeat',
                      onPressed: () => _repeat(context, a),
                    ),
                    if (a.kind == AppointmentKind.vet) ...[
                      const SizedBox(height: 10),
                      HuButton(
                        label: 'Ver informe en el historial',
                        icon: 'i-doc',
                        variant: HuButtonVariant.soft,
                        onPressed: () {
                          context
                              .read<PetsBloc>()
                              .add(PetSelected(a.petId, tab: 'hist'));
                          context.push('/pet');
                        },
                      ),
                    ],
                  ] else ...[
                    HuButton(
                      label: 'Reservar de nuevo',
                      icon: 'i-repeat',
                      onPressed: () => _repeat(context, a),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.leadingAvatarKey,
    this.isTotal = false,
    this.isLast = false,
  });

  final String icon;
  final String label;
  final String value;
  final String? leadingAvatarKey;
  final bool isTotal;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: HuIcon(icon, size: 20, color: t.ink3),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: t.style(14.5, FontWeight.w600, t.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leadingAvatarKey != null) ...[
                  HuPersonAvatar(
                    leadingAvatarKey!,
                    size: 26,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: t.style(
                      isTotal ? 18 : 14.5,
                      FontWeight.w600,
                      t.ink,
                      1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSquare extends StatelessWidget {
  const _ActionSquare({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: t.border),
          boxShadow: HuTokens.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HuIcon(icon, size: 22, color: t.teal),
            const SizedBox(height: 6),
            Text(label, style: t.style(12.5, FontWeight.w600, t.ink)),
          ],
        ),
      ),
    );
  }
}
