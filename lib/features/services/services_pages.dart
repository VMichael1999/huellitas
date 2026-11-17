import 'dart:math' as math;

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
import '../appointments/appointments_bloc.dart';
import '../pets/pet_wizard_bloc.dart';
import '../pets/pets_bloc.dart';
import 'service_booking_bloc.dart';

/// Pantalla 16: Grooming y servicios (`s-services`, «Grooming & Services»).
class ServicesListPage extends StatelessWidget {
  const ServicesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final pets = context.watch<PetsBloc>().state.pets;
    final appts = context.watch<AppointmentsBloc>().state.appointments;
    final p0 = pets.firstOrNull;

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Grooming y servicios',
        subtitle: 'El mejor cuidado para tu mascota',
        centered: false,
        onBack: () => context.pop(),
        trailing: HuHeaderCircleButton(
          icon: 'i-cal',
          label: 'Mis citas',
          tealSoft: true,
          onTap: () => context.go('/appts'),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 136), 22, 50),
        child: Column(
          children: [
            for (final s in DemoData.services)
              Builder(
                builder: (_) {
                  final price = s.sizePrices != null
                      ? s.sizePrices![p0 != null
                              ? PetHealthRules.sizeOf(p0.weightKg)
                              : 'M'] ??
                          45.0
                      : s.walkPrices != null
                          ? s.walkPrices![30] ?? 20.0
                          : s.price ?? 15.0;
                  final durLabel = s.kind == ServiceKind.range
                      ? 'Por noche'
                      : s.kind == ServiceKind.walk
                          ? '30 min'
                          : '${s.minutes} min';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: t.border),
                      boxShadow: HuTokens.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 132,
                          height: 132,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: s.accent.serviceCardBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: HuArt(s.artKey, width: 112, height: 112),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SizedBox(
                            height: 132,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 4, 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      HuDqIcon(
                                        s.dqIcon,
                                        color: Color(s.dqColorHex),
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: t.style(
                                            16,
                                            FontWeight.w600,
                                            t.ink,
                                            1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        durLabel,
                                        style: t.style(
                                          13.5,
                                          FontWeight.w400,
                                          t.ink2,
                                        ),
                                      ),
                                      Text(
                                        Money.usd(price),
                                        style: t.style(
                                          19,
                                          FontWeight.w600,
                                          t.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  HuPressable(
                                    onTap: () {
                                      if (pets.isEmpty) {
                                        context.read<PetWizardBloc>().add(
                                              const PetWizardStarted(
                                                isFirstPet: true,
                                              ),
                                            );
                                        context.push('/pet/new');
                                        return;
                                      }
                                      context.read<ServiceBookingBloc>().add(
                                            ServiceBookingOpened(
                                              serviceId: s.id,
                                              pet: pets.first,
                                              appointments: appts,
                                            ),
                                          );
                                      context.push('/service/book');
                                    },
                                    child: Container(
                                      height: 42,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: t.teal,
                                        borderRadius: BorderRadius.circular(21),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0xE6157A6F),
                                            offset: Offset(0, 8),
                                            blurRadius: 14,
                                            spreadRadius: -10,
                                          ),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Reservar',
                                        style: t.style(
                                          15,
                                          FontWeight.w500,
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Pantalla 17: Reservar servicio (`s-svc`: grooming, uñas, spa, hospedaje, paseo).
class ServiceBookingPage extends StatelessWidget {
  const ServiceBookingPage({super.key});

  Future<void> _confirm(
    BuildContext context,
    ServiceBookingState sv,
    Pet pet,
  ) async {
    if (!sv.isValid) return;
    final svBloc = context.read<ServiceBookingBloc>();
    svBloc.add(const ServiceBookingSubmittingSet(true));
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!context.mounted) return;
    svBloc.add(const ServiceBookingSubmittingSet(false));

    final s = sv.service;
    final apptsBloc = context.read<AppointmentsBloc>();
    final newSeq = apptsBloc.state.sequence + 1;
    final id = 'HU-$newSeq';

    final appt = Appointment(
      id: id,
      kind: AppointmentKind.svc,
      petId: pet.id,
      serviceId: s.id,
      date: sv.selectedDate!,
      time: s.kind == ServiceKind.range ? '09:00' : sv.selectedTime!,
      endDate: sv.endDate,
      status: AppointmentStatus.confirmed,
      price: sv.totalPrice,
      size: s.sizePrices != null ? sv.size : null,
      extras: sv.extras.toList(),
      pickup: sv.pickup,
      walkerId: s.kind == ServiceKind.walk ? sv.walkerId : null,
    );

    final doneTitle = s.kind == ServiceKind.walk
        ? '¡Paseo reservado!'
        : s.kind == ServiceKind.range
            ? '¡Hospedaje reservado!'
            : '¡Servicio reservado!';
    final doneSub = s.kind == ServiceKind.walk
        ? '${DemoData.walkerById(sv.walkerId).firstName} recogerá a ${pet.name} en tu casa. Podrás seguir el paseo en vivo.'
        : 'Te esperamos con ${pet.name}.${sv.pickup ? ' Pasaremos a recogerlo a tu casa.' : ''}';

    apptsBloc.add(AppointmentCreated(
      appointment: appt,
      doneTitle: doneTitle,
      doneSubtitle: doneSub,
    ));
    context.go('/done');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final clock = getIt<Clock>();
    final today = clock.today;
    final petsState = context.watch<PetsBloc>().state;
    final appts = context.watch<AppointmentsBloc>().state.appointments;
    final svBloc = context.watch<ServiceBookingBloc>();
    final sv = svBloc.state;

    final pets = petsState.pets;
    if (pets.isEmpty) {
      return HuScaffold(
        topBar: HuTopBar(title: '', clear: true, onBack: () => context.pop()),
        body: const SizedBox.shrink(),
      );
    }

    final pet = pets.firstWhere(
      (p) => p.id == sv.petId,
      orElse: () => pets.first,
    );
    final s = sv.service;
    final days = svBloc.next14Days;
    final slots = sv.selectedDate != null
        ? (svBloc.availability.slotsFor(
              key: sv.availabilityKey,
              clinic: sv.clinic,
              dateIso: sv.selectedDate!,
              durationMinutes: sv.durationMinutes,
              appointments: appts,
            ) ??
            const <TimeSlot>[])
        : const <TimeSlot>[];

    final summarySub = s.kind == ServiceKind.range
        ? (sv.nights > 0 && sv.selectedDate != null
            ? '${sv.nights} noches desde el ${HuFormat.fShort(sv.selectedDate!)}'
            : 'Elige las fechas')
        : (sv.selectedTime != null && sv.selectedDate != null
            ? '${HuFormat.fShort(sv.selectedDate!)} · ${HuFormat.ampm(sv.selectedTime!)}'
            : 'Elige la hora');

    return HuScaffold(
      showVeil: false,
      topBar: HuTopBar(
        title: '',
        clear: true,
        onBack: () => context.pop(),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.24, 1.0],
            colors: [
              t.bg.withValues(alpha: 0.0),
              t.bg,
              t.bg,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SummaryBar(
              leading: PetAvatar(
                artKey: pet.artKey,
                accent: pet.accent,
                size: 38,
                radius: 12,
              ),
              title: '${s.name} · ${pet.name}',
              subtitle: summarySub,
              totalText: Money.usd(sv.totalPrice),
            ),
            HuButton(
              loading: sv.submitting,
              label: sv.submitting
                  ? 'Reservando…'
                  : 'Reservar · ${Money.usd(sv.totalPrice)}',
              onPressed: sv.isValid ? () => _confirm(context, sv, pet) : null,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera ilustrada .shero
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, s.accent.bg],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(38),
                ),
              ),
              alignment: Alignment.center,
              child: HuArt(s.artKey, width: 210, height: 210),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Text(s.name, style: t.h1Large),
                  const SizedBox(height: 4),
                  Text(
                    s.description,
                    style: t.style(14.5, FontWeight.w600, t.ink2, 1.5),
                  ),

                  // ¿Para quién?
                  const HuSectionHeader('¿Para quién?'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final p in pets)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: HuPressable(
                              onTap: () =>
                                  svBloc.add(ServiceBookingPetChanged(p)),
                              selected: p.id == pet.id,
                              child: Container(
                                width: 96,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: p.id == pet.id
                                      ? t.tealSoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: p.id == pet.id ? t.teal : t.line,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    PetAvatar(
                                      artKey: p.artKey,
                                      accent: p.accent,
                                      size: 62,
                                      circular: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.name,
                                      style: t.style(
                                        14,
                                        FontWeight.w600,
                                        t.ink,
                                      ),
                                    ),
                                    Text(
                                      '${p.weightKg} kg',
                                      style: t.style(
                                        11.5,
                                        FontWeight.w600,
                                        t.ink2,
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

                  // Paseo: Duración y Paseador
                  if (s.kind == ServiceKind.walk) ...[
                    const HuSectionHeader('Duración'),
                    Row(
                      children: [
                        for (final (idx, d) in [30, 60].indexed) ...[
                          if (idx > 0) const SizedBox(width: 10),
                          Expanded(
                            child: HuPressable(
                              onTap: () => svBloc
                                  .add(ServiceBookingDurationChanged(d)),
                              selected: sv.walkDuration == d,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: sv.walkDuration == d
                                      ? t.tealSoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: sv.walkDuration == d
                                        ? t.teal
                                        : t.line,
                                    width: 1.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '$d min · ${Money.usd(s.walkPrices![d]!)}',
                                  style: t.style(
                                    14.5,
                                    FontWeight.w600,
                                    sv.walkDuration == d
                                        ? t.tealDeep
                                        : t.ink2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const HuSectionHeader('Paseador', topMargin: 16),
                    for (final w in DemoData.walkers)
                      HuCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        selected: sv.walkerId == w.id,
                        onTap: () =>
                            svBloc.add(ServiceBookingWalkerChanged(w.id)),
                        child: Row(
                          children: [
                            HuPersonAvatar(
                              w.avatarKey,
                              size: 46,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.name,
                                    style: t.style(
                                      15.5,
                                      FontWeight.w600,
                                      t.ink,
                                    ),
                                  ),
                                  Text(
                                    '★ ${w.rating} · ${w.walks} paseos · verificado',
                                    style: t.style(
                                      13,
                                      FontWeight.w600,
                                      t.ink2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _RadioIndicator(selected: sv.walkerId == w.id),
                          ],
                        ),
                      ),
                  ],

                  // Tamaño de la mascota (grooming)
                  if (s.sizePrices != null) ...[
                    HuSectionHeader(
                      'Tamaño de ${pet.name}',
                      trailingText: '${pet.weightKg} kg',
                    ),
                    Row(
                      children: [
                        for (final (idx, z) in ['S', 'M', 'L'].indexed) ...[
                          if (idx > 0) const SizedBox(width: 10),
                          Expanded(
                            child: HuPressable(
                              onTap: () =>
                                  svBloc.add(ServiceBookingSizeChanged(z)),
                              selected: sv.size == z,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: sv.size == z
                                      ? t.tealSoft
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: sv.size == z ? t.teal : t.line,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      PetHealthRules.sizeLabels[z]!.$1,
                                      style: t.style(
                                        15,
                                        FontWeight.w600,
                                        t.ink,
                                      ),
                                    ),
                                    Text(
                                      PetHealthRules.sizeLabels[z]!.$2,
                                      style: t.style(
                                        11.5,
                                        FontWeight.w600,
                                        t.ink2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Money.usd(s.sizePrices![z]!),
                                      style: t.style(
                                        15,
                                        FontWeight.w600,
                                        t.tealDeep,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],

                  // Extras
                  if (s.extras.isNotEmpty) ...[
                    const HuSectionHeader('Extras'),
                    for (final extKey in s.extras)
                      Builder(
                        builder: (_) {
                          final ext = DemoData.extras[extKey]!;
                          final isOn = sv.extras.contains(extKey);
                          return HuCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            selected: isOn,
                            onTap: () => svBloc
                                .add(ServiceBookingExtraToggled(extKey)),
                            child: Row(
                              children: [
                                const IconBox(
                                  icon: 'i-plus',
                                  accent: HuAccent.teal,
                                  size: 38,
                                  radius: 12,
                                  iconSize: 18,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    ext.name,
                                    style: t.style(
                                      15.5,
                                      FontWeight.w600,
                                      t.ink,
                                    ),
                                  ),
                                ),
                                Text(
                                  '+${Money.usd(ext.price)}',
                                  style: t.style(15, FontWeight.w600, t.ink),
                                ),
                                const SizedBox(width: 12),
                                _RadioIndicator(selected: isOn),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ],
              ),
            ),

            // Fecha y hora (slot o walk) vs Rango de fechas (hospedaje)
            if (s.kind == ServiceKind.slot || s.kind == ServiceKind.walk) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: HuSectionHeader(
                  '¿Cuándo?',
                  trailingText: sv.selectedDate != null
                      ? HuFormat.cap(
                          HuFormat.monLong[
                              HuFormat.fromIso(sv.selectedDate!).month - 1],
                        )
                      : '',
                ),
              ),
              DayStrip(
                today: today,
                days: days,
                selectedDate: sv.selectedDate,
                isEnabled: (d) =>
                    svBloc.availability.freeCount(
                      key: sv.availabilityKey,
                      clinic: sv.clinic,
                      dateIso: d,
                      durationMinutes: sv.durationMinutes,
                      appointments: appts,
                    ) >
                    0,
                onSelect: (d) => svBloc.add(ServiceBookingDaySelected(d)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 48,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, idx) {
                    final sl = slots[idx];
                    final hm = HuFormat.hm(sl.minutes);
                    final isOn = sv.selectedTime == hm;
                    if (sl.taken) {
                      return CustomPaint(
                        painter: _DashedSlotPainter(color: t.line),
                        child: Center(
                          child: Text(
                            HuFormat.ampm(hm),
                            style: t
                                .style(
                                  14.5,
                                  FontWeight.w600,
                                  const Color(0xFFC8D3DA),
                                )
                                .copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                          ),
                        ),
                      );
                    }
                    return HuPressable(
                      onTap: () => svBloc.add(ServiceBookingTimeSelected(hm)),
                      selected: isOn,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isOn ? t.teal : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isOn ? t.teal : t.line,
                            width: 1.5,
                          ),
                          boxShadow: isOn
                              ? const [
                                  BoxShadow(
                                    color: Color(0xE6157A6F),
                                    offset: Offset(0, 10),
                                    blurRadius: 18,
                                    spreadRadius: -12,
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          HuFormat.ampm(hm),
                          style: t.style(
                            14.5,
                            FontWeight.w600,
                            isOn ? Colors.white : t.ink,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (s.kind == ServiceKind.slot)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: ToggleRow(
                    icon: 'i-truck',
                    accent: HuAccent.coral,
                    title: 'Recojo a domicilio',
                    subtitle:
                        'Lo recogemos y lo devolvemos · +${Money.usd(BookingPricingRules.pickupFee)}',
                    value: sv.pickup,
                    onChanged: (_) =>
                        svBloc.add(const ServiceBookingPickupToggled()),
                  ),
                ),
            ] else ...[
              // Hospedaje (range)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HuSectionHeader(
                      'Fechas',
                      trailingText: sv.selectedDate != null && sv.endDate == null
                          ? 'Ahora elige la salida'
                          : 'Toca la entrada y luego la salida',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sv.selectedDate == null
                                    ? t.teal
                                    : t.line,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Entrada',
                                  style: t.style(12, FontWeight.w600, t.ink2),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sv.selectedDate != null
                                      ? HuFormat.cap(
                                          HuFormat.fShort(sv.selectedDate!),
                                        )
                                      : '—',
                                  style: t.style(17, FontWeight.w600, t.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: sv.selectedDate != null &&
                                        sv.endDate == null
                                    ? t.teal
                                    : t.line,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salida',
                                  style: t.style(12, FontWeight.w600, t.ink2),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sv.endDate != null
                                      ? HuFormat.cap(
                                          HuFormat.fShort(sv.endDate!),
                                        )
                                      : '—',
                                  style: t.style(17, FontWeight.w600, t.ink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DayStrip(
                today: today,
                days: days,
                selectedDate: sv.selectedDate,
                endDate: sv.endDate,
                onSelect: (d) => svBloc.add(ServiceBookingRangeDayTapped(d)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    if (sv.nights > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: HuInfoBox(
                          icon: 'i-moon2',
                          text:
                              '${sv.nights} ${sv.nights == 1 ? 'noche' : 'noches'} · entrada desde las 9:00 a. m., salida hasta las 6:00 p. m. Incluye fotos diarias.',
                        ),
                      ),
                    ToggleRow(
                      icon: 'i-truck',
                      accent: HuAccent.coral,
                      title: 'Recojo a domicilio',
                      subtitle:
                          'Ida y vuelta · +${Money.usd(BookingPricingRules.pickupFee)}',
                      value: sv.pickup,
                      onChanged: (_) =>
                          svBloc.add(const ServiceBookingPickupToggled()),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? t.teal : t.line,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: t.teal,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _DashedSlotPainter extends CustomPainter {
  _DashedSlotPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(15),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, math.min(d + 5, m.length)), paint);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSlotPainter oldDelegate) => false;
}
