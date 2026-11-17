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
import '../../core/widgets/illustrated_map.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../booking/booking_bloc.dart';
import '../pets/pet_wizard_bloc.dart';
import '../pets/pets_bloc.dart';
import 'vets_cubit.dart';

void openClinicDetailSheet(BuildContext context, Clinic clinic) {
  final clinicVets =
      DemoData.vets.where((v) => v.clinicId == clinic.id).toList();
  showHuSheet(
    context,
    builder: (ctx) {
      final t = ctx.hu;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconBox(
                icon: clinic.is24h ? 'i-alert' : 'i-steth',
                accent: clinic.is24h ? HuAccent.bad : HuAccent.teal,
                size: 52,
                radius: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clinic.name,
                      style: t.style(22, FontWeight.w600, t.ink, 1.15),
                    ),
                    Text(
                      '${clinic.address} · ${clinic.km} km',
                      style: t.style(13, FontWeight.w700, t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GoogleMapView(
            height: 140,
            singlePinColor: clinic.is24h ? t.bad : t.teal,
          ),
          const SizedBox(height: 12),
          HuCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      HuIcon('i-clock', size: 20, color: t.ink3),
                      const SizedBox(width: 12),
                      Text(
                        'Horario',
                        style: t.style(14.5, FontWeight.w600, t.ink2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          clinic.hoursLabel,
                          textAlign: TextAlign.end,
                          style: t.style(14.5, FontWeight.w600, t.ink),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: t.line, height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      HuIcon('i-phone', size: 20, color: t.ink3),
                      const SizedBox(width: 12),
                      Text(
                        'Teléfono',
                        style: t.style(14.5, FontWeight.w600, t.ink2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          clinic.phone,
                          textAlign: TextAlign.end,
                          style: t.style(14.5, FontWeight.w600, t.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Atienden aquí',
            style: t.style(13, FontWeight.w500, t.ink2),
          ),
          const SizedBox(height: 8),
          for (final v in clinicVets)
            HuCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () {
                Navigator.of(ctx).pop();
                context.read<VetsCubit>().selectVet(v.id);
                context.push('/vet');
              },
              child: Row(
                children: [
                  HuPersonAvatar(
                    v.avatarKey,
                    size: 46,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.name,
                          style: t.style(15.5, FontWeight.w600, t.ink),
                        ),
                        Text(
                          v.specialty,
                          style: t.style(12.5, FontWeight.w600, t.ink2),
                        ),
                      ],
                    ),
                  ),
                  HuIcon('i-chev', size: 20, color: t.ink3),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: HuButton(
                  label: 'Llamar',
                  icon: 'i-phone',
                  variant: HuButtonVariant.soft,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    getIt<Toaster>().show('Llamando a ${clinic.name}…');
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: HuButton(
                  label: 'Cómo llegar',
                  icon: 'i-map',
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    getIt<Toaster>().show('Abriendo el mapa con la ruta.');
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

class _ClinicCardRow extends StatelessWidget {
  const _ClinicCardRow({required this.clinic, required this.clock});
  final Clinic clinic;
  final Clock clock;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final open = VetSpec.isClinicOpen(clock, clinic);
    return HuCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => openClinicDetailSheet(context, clinic),
      child: Row(
        children: [
          IconBox(
            icon: clinic.is24h ? 'i-alert' : 'i-steth',
            accent: clinic.is24h ? HuAccent.bad : HuAccent.teal,
            size: 48,
            radius: 15,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(clinic.name, style: t.style(15, FontWeight.w600, t.ink)),
                const SizedBox(height: 2),
                Text(
                  '${clinic.address} · ${clinic.km} km',
                  style: t.style(12.5, FontWeight.w600, t.ink2),
                ),
                const SizedBox(height: 6),
                StatusTag(
                  clinic.is24h
                      ? 'Abierto 24 h'
                      : open
                          ? 'Abierto ahora'
                          : 'Cerrado ahora',
                  accent: open ? HuAccent.ok : HuAccent.muted,
                ),
              ],
            ),
          ),
          HuIcon('i-chev', size: 20, color: t.ink3),
        ],
      ),
    );
  }
}

/// Pantalla 14: Veterinarias cerca (`s-vets`, modo lista y modo mapa).
class VetsNearPage extends StatelessWidget {
  const VetsNearPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final clock = getIt<Clock>();
    final today = clock.today;
    final avail = AvailabilityService(clock: clock);
    final appts = context.watch<AppointmentsBloc>().state.appointments;
    final vetsState = context.watch<VetsCubit>().state;
    final f = vetsState.filter;

    final filteredClinics = DemoData.clinics.where((c) {
      if (f == 'all') return true;
      if (f == 'open') return VetSpec.isClinicOpen(clock, c);
      if (f == 'h24') return c.is24h;
      if (f == 'cat') {
        return DemoData.vets.any((v) =>
            v.clinicId == c.id &&
            v.species.contains(PetSpecies.cat) &&
            v.id == 'camila');
      }
      if (f == 'derm') {
        return DemoData.vets
            .any((v) => v.clinicId == c.id && v.id == 'andres');
      }
      return true;
    }).toList();

    final filteredVets = DemoData.vets.where((v) {
      if (!filteredClinics.any((c) => c.id == v.clinicId)) return false;
      if (f == 'cat' && v.id != 'camila') return false;
      if (f == 'derm' && v.id != 'andres') return false;
      return true;
    }).toList();

    const filterOptions = [
      ('all', 'Todas'),
      ('open', 'Abierto ahora'),
      ('h24', '24 horas'),
      ('cat', 'Gatos'),
      ('derm', 'Piel y alergias'),
    ];

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Veterinarias cerca',
        onBack: () => context.pop(),
        trailing: HuHeaderCircleButton(
          icon: vetsState.mode == 'list' ? 'i-map' : 'i-list',
          label: vetsState.mode == 'list' ? 'Ver mapa' : 'Ver lista',
          onTap: () => context.read<VetsCubit>().toggleMode(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (k, label) in filterOptions)
                    Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 16),
                      child: HuChip(
                        label: label,
                        selected: f == k,
                        onTap: () => context.read<VetsCubit>().setFilter(k),
                      ),
                    ),
                ],
              ),
            ),

            if (vetsState.mode == 'map') ...[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: HuTokens.cardShadow,
                ),
                child: GoogleMapView(
                  height: 420,
                  borderRadius: 24,
                  largeMode: true,
                  pins: [
                    for (final c in filteredClinics)
                      MapPinData(
                        id: c.id,
                        xPercent: c.mapX,
                        yPercent: c.mapY,
                        label: c.name.replaceAll(
                          'Hospital Veterinario',
                          'Hospital',
                        ),
                        is24h: c.is24h,
                        onTap: () => openClinicDetailSheet(context, c),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
                child: Text(
                  '${filteredClinics.length} ${filteredClinics.length == 1 ? 'clínica' : 'clínicas'} en el mapa',
                  style: t.style(13, FontWeight.w500, t.ink2),
                ),
              ),
              for (final c in filteredClinics)
                _ClinicCardRow(clinic: c, clock: clock),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
                child: Text(
                  'Clínicas',
                  style: t.style(13, FontWeight.w500, t.ink2),
                ),
              ),
              if (filteredClinics.isEmpty)
                Text(
                  'Ninguna clínica con este filtro.',
                  style: t.style(14.5, FontWeight.w400, t.ink2),
                )
              else
                for (final c in filteredClinics)
                  _ClinicCardRow(clinic: c, clock: clock),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 18, 2, 10),
                child: Text(
                  'Veterinarios',
                  style: t.style(13, FontWeight.w500, t.ink2),
                ),
              ),
              for (final v in filteredVets)
                Builder(
                  builder: (_) {
                    final nf = avail.nextFree(
                      key: v.id,
                      clinic: DemoData.clinicById(v.clinicId),
                      durationMinutes: 30,
                      appointments: appts,
                    );
                    return HuCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      onTap: () {
                        context.read<VetsCubit>().selectVet(v.id);
                        context.push('/vet');
                      },
                      child: Row(
                        children: [
                          HuPersonAvatar(
                            v.avatarKey,
                            size: 58,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.name,
                                  style: t.style(15.5, FontWeight.w600, t.ink),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '${v.specialty} · ${DemoData.clinicById(v.clinicId).name}',
                                  style: t.style(12.5, FontWeight.w600, t.ink2),
                                ),
                                const SizedBox(height: 5),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        HuIcon(
                                          'i-star',
                                          size: 13,
                                          color: t.sun,
                                          fill: t.sun,
                                          strokeWidth: 0,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${v.rating.toStringAsFixed(1)} (${v.reviews})',
                                          style: t.style(
                                            12,
                                            FontWeight.w500,
                                            t.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    StatusTag(
                                      HuFormat.nfLabel(today, nf),
                                      accent: HuAccent.ok,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          HuIcon('i-chev', size: 20, color: t.ink3),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pantalla 15: Perfil del veterinario (`s-vet`).
class VetProfilePage extends StatelessWidget {
  const VetProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final clock = getIt<Clock>();
    final today = clock.today;
    final avail = AvailabilityService(clock: clock);
    final appts = context.watch<AppointmentsBloc>().state.appointments;
    final pets = context.watch<PetsBloc>().state.pets;
    final vetId = context.watch<VetsCubit>().state.selectedVetId;
    final v = DemoData.vetById(vetId);
    final clinic = DemoData.clinicById(v.clinicId);
    final nf = avail.nextFree(
      key: v.id,
      clinic: clinic,
      durationMinutes: 30,
      appointments: appts,
    );

    final firstNameOnly = v.shortName
        .replaceAll('Dra. ', '')
        .replaceAll('Dr. ', '');
    final patsFormatted = (v.patients / 1000.0)
        .toStringAsFixed(1)
        .replaceAll('.0', '');
    final speciesLabel = v.species
        .map((s) => switch (s) {
              PetSpecies.dog => 'Perros',
              PetSpecies.cat => 'Gatos',
              PetSpecies.other => 'Otras especies',
            })
        .join(' · ');

    return HuScaffold(
      topBar: HuTopBar(
        title: '',
        onBack: () => context.pop(),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [t.bg.withValues(alpha: 0.0), t.bg],
          ),
        ),
        child: HuButton(
          label: 'Reservar con ${v.shortName}',
          onPressed: () {
            if (pets.isEmpty) {
              context
                  .read<PetWizardBloc>()
                  .add(const PetWizardStarted(isFirstPet: true));
              context.push('/pet/new');
              return;
            }
            context.read<BookingBloc>().add(BookingStarted(
                  pets: pets,
                  appointments: appts,
                  vetId: v.id,
                ));
            context.push('/book');
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, HuLayout.top(context, 110), 0, 140),
        child: Column(
          children: [
            // Cabecera centrada .vhd
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: Colors.white, width: 6),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x9912324A),
                          offset: Offset(0, 18),
                          blurRadius: 30,
                          spreadRadius: -18,
                        ),
                      ],
                    ),
                    child: HuPersonAvatar(
                      v.avatarKey,
                      size: 104,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    v.name,
                    textAlign: TextAlign.center,
                    style: t.h1Large,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.specialty,
                    style: t.style(14.5, FontWeight.w700, t.ink2),
                  ),
                  const SizedBox(height: 10),
                  StatusTag(
                    'Próxima hora: ${HuFormat.nfLabel(today, nf)}',
                    accent: HuAccent.ok,
                    icon: 'i-clock',
                    height: 30,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats (3 columnas)
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          top: Row(
                            mainAxisSize: MainAxisSize.min,
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
                                v.rating.toStringAsFixed(1),
                                style: t.style(20, FontWeight.w600, t.ink),
                              ),
                            ],
                          ),
                          bottom: '${v.reviews} reseñas',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                          top: Text(
                            '${v.years}',
                            style: t.style(20, FontWeight.w600, t.ink),
                          ),
                          bottom: 'años',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                          top: Text(
                            '$patsFormatted mil',
                            style: t.style(20, FontWeight.w600, t.ink),
                          ),
                          bottom: 'pacientes',
                        ),
                      ),
                    ],
                  ),

                  HuSectionHeader('Sobre $firstNameOnly'),
                  Text(
                    v.about,
                    style: t.style(14.5, FontWeight.w600, t.ink2, 1.55),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in v.tags) StatusTag(tag),
                      StatusTag(speciesLabel, accent: HuAccent.lav),
                    ],
                  ),

                  const HuSectionHeader('Dónde atiende'),
                  _ClinicCardRow(clinic: clinic, clock: clock),

                  const HuSectionHeader('Reseñas'),
                  for (final rev in DemoData.vetReviews.take(2))
                    HuCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: t.chip,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  rev.$1[0],
                                  style: t.style(14, FontWeight.w700, t.ink2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rev.$1,
                                      style: t.style(
                                        14.5,
                                        FontWeight.w600,
                                        t.ink,
                                      ),
                                    ),
                                    Text(
                                      rev.$4,
                                      style: t.style(
                                        12,
                                        FontWeight.w600,
                                        t.ink3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              HuStars(rev.$2.toDouble()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rev.$3,
                            style: t.style(14, FontWeight.w400, t.ink2, 1.5),
                          ),
                        ],
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.top, required this.bottom});
  final Widget top;
  final String bottom;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: t.border),
        boxShadow: HuTokens.cardShadow,
      ),
      child: Column(
        children: [
          top,
          const SizedBox(height: 2),
          Text(bottom, style: t.style(12, FontWeight.w500, t.ink2)),
        ],
      ),
    );
  }
}
