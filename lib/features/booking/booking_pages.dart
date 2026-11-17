import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/illustrated_map.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../notifications/notifications_cubit.dart';
import '../pets/pets_bloc.dart';
import 'booking_bloc.dart';

/// Hoja de selección de veterinario ordenada por hora libre más cercana.
Widget buildVetPickerSheet(
  BuildContext context, {
  required List<({Vet vet, ({String d, int t})? nextFree})> sortedVets,
  required String? selectedVetId,
  required DateTime today,
  required ValueChanged<String> onSelectVet,
}) {
  final t = context.hu;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Selecciona el veterinario',
        style: t.style(23, FontWeight.w600, t.ink, 1.15),
      ),
      const SizedBox(height: 4),
      Text(
        'Ordenados por la hora libre más cercana.',
        style: t.style(14.5, FontWeight.w400, t.ink2),
      ),
      const SizedBox(height: 14),
      for (final item in sortedVets)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: HuPressable(
            onTap: () => onSelectVet(item.vet.id),
            selected: item.vet.id == selectedVetId,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: item.vet.id == selectedVetId
                    ? const Color(0xFFF4FBFA)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: item.vet.id == selectedVetId ? t.teal : t.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  HuPersonAvatar(item.vet.avatarKey, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.vet.name,
                          style: t.style(15.5, FontWeight.w600, t.ink, 1.3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.vet.specialty} · ${DemoData.clinicById(item.vet.clinicId).name}',
                          style: t.style(13, FontWeight.w400, t.ink2),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            HuIcon('i-clock', size: 14, color: t.tealDeep),
                            const SizedBox(width: 5),
                            Text(
                              HuFormat.nfLabel(today, item.nextFree),
                              style: t.style(13, FontWeight.w500, t.tealDeep),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (item.vet.id == selectedVetId)
                    HuIcon('i-check', size: 22, color: t.teal),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

/// Hoja de selección de tipo de cita con duración y precio.
Widget buildTypePickerSheet(
  BuildContext context, {
  required String petName,
  required String selectedTypeId,
  required ValueChanged<String> onSelectType,
}) {
  final t = context.hu;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Tipo de cita',
        style: t.style(23, FontWeight.w600, t.ink, 1.15),
      ),
      const SizedBox(height: 4),
      Text(
        'Para $petName. Pagas en la clínica.',
        style: t.style(14.5, FontWeight.w400, t.ink2),
      ),
      const SizedBox(height: 14),
      for (final vt in DemoData.visitTypes)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: HuPressable(
            onTap: () => onSelectType(vt.id),
            selected: vt.id == selectedTypeId,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: vt.id == selectedTypeId
                    ? const Color(0xFFF4FBFA)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: vt.id == selectedTypeId ? t.teal : t.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  IconBox(
                    icon: vt.icon,
                    accent: vt.accent,
                    size: 46,
                    radius: 14,
                    iconSize: 24,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vt.name,
                          style: t.style(15.5, FontWeight.w600, t.ink, 1.3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vt.description,
                          style: t.style(13, FontWeight.w400, t.ink2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${vt.minutes} min · ${Money.usd(vt.price)}',
                          style: t.style(13, FontWeight.w500, t.tealDeep),
                        ),
                      ],
                    ),
                  ),
                  if (vt.id == selectedTypeId)
                    HuIcon('i-check', size: 22, color: t.teal),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

/// Pantalla 9: Reservar cita (`s-book`, una sola pantalla).
class BookAppointmentPage extends StatelessWidget {
  const BookAppointmentPage({super.key});

  Future<void> _confirm(
    BuildContext context,
    BookingState bk,
    Pet pet,
  ) async {
    if (bk.selectedTime == null || bk.selectedDate == null) return;

    if (bk.isReschedule && bk.rescheduleAppointmentId != null) {
      context.read<AppointmentsBloc>().add(AppointmentRescheduled(
            appointmentId: bk.rescheduleAppointmentId!,
            newDate: bk.selectedDate!,
            newTime: bk.selectedTime!,
          ));
      context.pop();
      getIt<Toaster>().show(
        'Listo. Nueva fecha: ${HuFormat.fShort(bk.selectedDate!)} a las ${HuFormat.ampm(bk.selectedTime!)}.',
      );
      return;
    }

    final bookingBloc = context.read<BookingBloc>();
    bookingBloc.add(const BookingSubmittingSet(true));
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!context.mounted) return;
    bookingBloc.add(const BookingSubmittingSet(false));

    final vt = bk.visitType;
    final vet = bk.vet ?? DemoData.vets.first;
    final apptsBloc = context.read<AppointmentsBloc>();
    final newSeq = apptsBloc.state.sequence + 1;
    final newId = 'HU-$newSeq';
    final appt = Appointment(
      id: newId,
      kind: AppointmentKind.vet,
      petId: pet.id,
      typeId: vt.id,
      vetId: vet.id,
      clinicId: vet.clinicId,
      date: bk.selectedDate!,
      time: bk.selectedTime!,
      status: AppointmentStatus.confirmed,
      price: vt.price,
    );

    apptsBloc.add(AppointmentCreated(
      appointment: appt,
      doneTitle: '¡Cita confirmada!',
      doneSubtitle:
          'Te esperamos con ${pet.name}. Te avisaremos un día antes.',
    ));

    context.read<NotificationsCubit>().addNotification(
          AppNotification(
            id: DateTime.now().millisecondsSinceEpoch,
            icon: 'i-checkc',
            accent: HuAccent.ok,
            title: 'Cita confirmada',
            subtitle:
                '${vt.name} para ${pet.name} con ${vet.shortName}, ${HuFormat.fShort(appt.date)} a las ${HuFormat.ampm(appt.time)}.',
            whenLabel: 'Ahora',
            unread: true,
            targetKind: 'appt',
            targetId: newId,
          ),
        );

    context.go('/done');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final clock = getIt<Clock>();
    final today = clock.today;
    final todayIso = HuFormat.iso(today);
    final limitIso = HuFormat.rd(today, 45);

    final petsState = context.watch<PetsBloc>().state;
    final apptsState = context.watch<AppointmentsBloc>().state;
    final bkBloc = context.watch<BookingBloc>();
    final bk = bkBloc.state;

    final pets = petsState.pets;
    if (pets.isEmpty) {
      return HuScaffold(
        topBar: HuTopBar(
          title: 'Reservar cita',
          centered: false,
          onBack: () => context.pop(),
        ),
        body: const Center(
          child: EmptyState(
            artKey: 'a-dog',
            title: 'Primero agrega a tu mascota',
            subtitle: 'Necesitamos su ficha para reservar una cita.',
          ),
        ),
      );
    }

    final pet = pets.firstWhere(
      (p) => p.id == bk.petId,
      orElse: () => pets.first,
    );
    final availKey = bk.availabilityKey;
    final freeSlots = bkBloc
        .freeSlotsForCurrentDate(bk, apptsState.appointments)
        .map((s) => s.minutes)
        .toList();
    final currentReschedAppt =
        bk.isReschedule ? apptsState.byId(bk.rescheduleAppointmentId) : null;

    final y = bk.calendarMonth.year;
    final mo = bk.calendarMonth.month;
    final canGoPrev = y * 12 + mo > today.year * 12 + today.month;
    final canGoNext =
        HuFormat.iso(DateTime(y, mo + 1, 1)).compareTo(limitIso) <= 0;

    return HuScaffold(
      topBar: HuTopBar(
        title: bk.isReschedule ? 'Cambiar fecha' : 'Reservar cita',
        centered: false,
        onBack: () => context.pop(),
      ),
      body: availKey == null
          ? Center(
              child: EmptyState(
                artKey: 'a-vet',
                title: 'Sin veterinarios disponibles',
                subtitle:
                    'No hay quien atienda a ${pet.name} para ${bk.visitType.name.toLowerCase()}. Prueba otro tipo de cita.',
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                22,
                HuLayout.top(context, 124),
                22,
                60,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips de mascota si hay más de una
                  if (pets.length > 1 && !bk.isReschedule)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final p in pets)
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: HuPressable(
                                  onTap: () => bkBloc.add(BookingPetChanged(
                                    petId: p.id,
                                    pets: pets,
                                    appointments: apptsState.appointments,
                                  )),
                                  selected: p.id == pet.id,
                                  child: Container(
                                    height: 46,
                                    padding:
                                        const EdgeInsets.fromLTRB(6, 0, 16, 0),
                                    decoration: BoxDecoration(
                                      color: p.id == pet.id
                                          ? t.tealSoft
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(23),
                                      border: Border.all(
                                        color: p.id == pet.id
                                            ? t.teal
                                            : t.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: t.chip,
                                            shape: BoxShape.circle,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: HuArt(
                                            p.artKey,
                                            width: 36,
                                            height: 36,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          p.name,
                                          style: t.style(
                                            14.5,
                                            FontWeight.w500,
                                            p.id == pet.id ? t.tealDeep : t.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  if (currentReschedAppt != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: HuInfoBox(
                        icon: 'i-cal',
                        accent: HuAccent.sun,
                        text:
                            'Tu cita actual: ${HuFormat.fShort(currentReschedAppt.date)} · ${HuFormat.ampm(currentReschedAppt.time)}',
                      ),
                    ),

                  // 1. Selecciona la fecha
                  Text(
                    'Selecciona la fecha',
                    style: t.style(17, FontWeight.w600, t.ink, 1.2),
                  ),
                  const SizedBox(height: 12),
                  MonthCalendar(
                    displayMonth: bk.calendarMonth,
                    selectedIsoDate: bk.selectedDate,
                    canGoPrev: canGoPrev,
                    canGoNext: canGoNext,
                    onPrevMonth: () =>
                        bkBloc.add(const BookingMonthChanged(-1)),
                    onNextMonth: () =>
                        bkBloc.add(const BookingMonthChanged(1)),
                    isDayEnabled: (di) {
                      if (di.compareTo(todayIso) < 0 ||
                          di.compareTo(limitIso) > 0) {
                        return false;
                      }
                      return bkBloc.availability.freeCount(
                            key: availKey,
                            clinic: bk.clinic,
                            dateIso: di,
                            durationMinutes: bk.durationMinutes,
                            appointments: apptsState.appointments,
                            ignoreAppointmentId: bk.rescheduleAppointmentId,
                          ) >
                          0;
                    },
                    onSelectDate: (di) => bkBloc.add(BookingDateSelected(
                      dateIso: di,
                      appointments: apptsState.appointments,
                    )),
                  ),

                  // 2. Selecciona la hora
                  const SizedBox(height: 24),
                  Text(
                    'Selecciona la hora',
                    style: t.style(17, FontWeight.w600, t.ink, 1.2),
                  ),
                  const SizedBox(height: 12),
                  SlotGrid(
                    freeSlotsMinutes: freeSlots,
                    selectedTime: bk.selectedTime,
                    showAll: bk.showAllSlots,
                    onSelectTime: (hm) => bkBloc.add(BookingTimeSelected(hm)),
                    onToggleShowAll: () =>
                        bkBloc.add(const BookingToggleShowAllSlots()),
                  ),

                  // 3. Selecciona el veterinario
                  if (!bk.isService && bk.vet != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Selecciona el veterinario',
                      style: t.style(17, FontWeight.w600, t.ink, 1.2),
                    ),
                    const SizedBox(height: 12),
                    PickerCard(
                      enabled: !bk.isReschedule,
                      leading: HuPersonAvatar(bk.vet!.avatarKey, size: 64),
                      title: bk.vet!.name,
                      subtitle: bk.vet!.specialty,
                      extraLine: Row(
                        children: [
                          HuIcon(
                            'i-star',
                            size: 16,
                            color: t.sun,
                            fill: t.sun,
                            strokeWidth: 0,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${bk.vet!.rating}',
                            style: t.style(13.5, FontWeight.w500, t.ink),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${bk.vet!.reviews} reseñas)',
                            style: t.style(13.5, FontWeight.w400, t.ink2),
                          ),
                        ],
                      ),
                      onTap: () {
                        final sorted = bkBloc.vetsSorted(
                          bk,
                          pets,
                          apptsState.appointments,
                        );
                        showHuSheet(
                          context,
                          builder: (ctx) => buildVetPickerSheet(
                            ctx,
                            sortedVets: sorted,
                            selectedVetId: bk.vetId,
                            today: today,
                            onSelectVet: (vId) {
                              Navigator.of(ctx).pop();
                              bkBloc.add(BookingVetChanged(
                                vetId: vId,
                                pets: pets,
                                appointments: apptsState.appointments,
                              ));
                            },
                          ),
                        );
                      },
                    ),
                  ],

                  // 4. Tipo de cita (o Servicio)
                  const SizedBox(height: 24),
                  Text(
                    bk.isService ? 'Servicio' : 'Tipo de cita',
                    style: t.style(17, FontWeight.w600, t.ink, 1.2),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (_) {
                      final isSvc = bk.isService;
                      final title = isSvc
                          ? DemoData.serviceById(bk.serviceId ?? 'groom').name
                          : bk.visitType.name;
                      final desc = isSvc
                          ? ''
                          : bk.visitType.description;
                      final ic =
                          isSvc ? 'i-scissors' : bk.visitType.icon;
                      return PickerCard(
                        enabled: !bk.isReschedule,
                        leading: IconBox(
                          icon: ic,
                          accent: HuAccent.teal,
                          size: 46,
                          radius: 14,
                          iconSize: 24,
                        ),
                        title: title,
                        subtitle: desc,
                        onTap: () {
                          showHuSheet(
                            context,
                            builder: (ctx) => buildTypePickerSheet(
                              ctx,
                              petName: pet.name,
                              selectedTypeId: bk.typeId,
                              onSelectType: (tId) {
                                Navigator.of(ctx).pop();
                                bkBloc.add(BookingTypeChanged(
                                  typeId: tId,
                                  pets: pets,
                                  appointments: apptsState.appointments,
                                ));
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 28),
                  HuButton(
                    height: 58,
                    radius: 18,
                    loading: bk.submitting,
                    label: bk.submitting
                        ? 'Confirmando…'
                        : bk.isReschedule
                            ? 'Guardar el cambio'
                            : 'Confirmar cita',
                    onPressed: bk.selectedTime != null
                        ? () => _confirm(context, bk, pet)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HuIcon('i-lock', size: 15, color: t.ink3),
                      const SizedBox(width: 7),
                      Text(
                        'Tu información está segura y protegida',
                        style: t.style(12.5, FontWeight.w600, t.ink3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

/// Pantalla 10 y 27: Pantalla de confirmación (`s-done`, cita o pedido confirmado).
class DonePage extends StatelessWidget {
  const DonePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final apptsState = context.watch<AppointmentsBloc>().state;
    final petsState = context.watch<PetsBloc>().state;
    final done = apptsState.doneData;

    if (done == null) {
      return HuScaffold(
        body: Center(
          child: HuButton(
            label: 'Volver al inicio',
            expand: false,
            onPressed: () => context.go('/home'),
          ),
        ),
      );
    }

    final appt =
        done.appointmentId != null ? apptsState.byId(done.appointmentId) : null;
    final order = done.order;

    return HuScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 90), 22, 40),
        child: Column(
          children: [
            const PawBurst(),
            const SizedBox(height: 18),
            Text(
              done.title,
              textAlign: TextAlign.center,
              style: t.style(32, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 4),
            Text(
              done.subtitle,
              textAlign: TextAlign.center,
              style: t.style(15, FontWeight.w400, t.ink2, 1.45),
            ),
            const SizedBox(height: 22),

            if (appt != null) ...[
              Builder(
                builder: (_) {
                  final pet =
                      petsState.byId(appt.petId) ?? petsState.pets.first;
                  final dateText =
                      '${HuFormat.cap(HuFormat.fShort(appt.date))}${appt.endDate != null ? ' al ${HuFormat.fShort(appt.endDate!)}' : ''} · ${HuFormat.ampm(appt.time)}';
                  return HuCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        PetAvatar(
                          artKey: pet.artKey,
                          accent: pet.accent,
                          size: 64,
                          radius: 18,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DemoData.appointmentTitle(appt),
                                style: t.style(18, FontWeight.w600, t.ink),
                              ),
                              Text(
                                '${pet.name} · ${DemoData.appointmentWho(appt)}',
                                style: t.style(13, FontWeight.w600, t.ink2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateText,
                                style: t.style(13.5, FontWeight.w700, t.ink),
                              ),
                            ],
                          ),
                        ),
                        StatusTag(Money.usd(appt.price)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              if (appt.kind == AppointmentKind.vet) ...[
                HuButton(
                  label: 'Añadir al calendario',
                  onPressed: () =>
                      getIt<Toaster>().show('Añadido a tu calendario.'),
                ),
                const SizedBox(height: 10),
                HuButton(
                  label: 'Ver detalle',
                  variant: HuButtonVariant.soft,
                  onPressed: () {
                    context
                        .read<AppointmentsBloc>()
                        .add(AppointmentSelected(appt.id));
                    context.go('/home');
                    context.push('/appt');
                  },
                ),
              ] else ...[
                HuButton(
                  label: 'Ver detalle',
                  onPressed: () {
                    context
                        .read<AppointmentsBloc>()
                        .add(AppointmentSelected(appt.id));
                    context.go('/home');
                    context.push('/appt');
                  },
                ),
              ],
              const SizedBox(height: 8),
              HuButton(
                label: 'Volver al inicio',
                variant: HuButtonVariant.linkMuted,
                onPressed: () => context.go('/home'),
              ),
            ] else if (order != null) ...[
              HuCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.id,
                          style: t.style(15, FontWeight.w700, t.ink),
                        ),
                        Text(
                          '${order.items} ${order.items == 1 ? 'producto' : 'productos'}',
                          style: t.style(14.5, FontWeight.w700, t.ink2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _OrderTrackingBar(),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              HuButton(
                label: 'Seguir comprando',
                onPressed: () {
                  context.go('/home');
                  context.push('/shop');
                },
              ),
              const SizedBox(height: 8),
              HuButton(
                label: 'Volver al inicio',
                variant: HuButtonVariant.linkMuted,
                onPressed: () => context.go('/home'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderTrackingBar extends StatelessWidget {
  const _OrderTrackingBar();

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    const steps = ['Pagado', 'Preparando', 'En camino', 'Entregado'];
    return Stack(
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: 13,
          child: Container(height: 3, color: t.line),
        ),
        Positioned(
          left: 24,
          width: 90,
          top: 13,
          child: Container(height: 3, color: t.teal),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final (idx, s) in steps.indexed)
              SizedBox(
                width: 72,
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: idx == 0 ? t.teal : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: idx == 0 ? t.teal : t.line,
                          width: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s,
                      textAlign: TextAlign.center,
                      style: t.style(
                        11.5,
                        FontWeight.w600,
                        idx == 0 ? t.tealDeep : t.ink3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
