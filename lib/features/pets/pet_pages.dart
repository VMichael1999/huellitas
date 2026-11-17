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
import '../../core/widgets/illustrated_map.dart';
import '../../core/widgets/toaster.dart';
import '../appointments/appointments_bloc.dart';
import '../booking/booking_bloc.dart';
import '../chat/chat_bloc.dart';
import '../reminders/reminders_bloc.dart';
import 'pet_wizard_bloc.dart';
import 'pets_bloc.dart';

/// Hoja «¿Cómo está Milo hoy?» para registrar peso, actividad, comida y ánimo.
void openPetDailyLogSheet(BuildContext context, Pet pet) {
  final weightCtrl = TextEditingController(text: '${pet.weightKg}');
  String act = pet.activity >= 70
      ? 'Mucha'
      : pet.activity >= 45
          ? 'Normal'
          : 'Poca';
  String food = pet.appetite;
  String mood = pet.mood;
  bool weightErr = false;

  showHuSheet(
    context,
    builder: (ctx) {
      final t = ctx.hu;
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          final tranquilLabel = pet.sex == 'Hembra' ? 'Tranquila' : 'Tranquilo';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Cómo está ${pet.name} hoy?',
                style: t.style(23, FontWeight.w600, t.ink, 1.15),
              ),
              const SizedBox(height: 4),
              Text(
                'Con esto actualizamos su resumen de salud.',
                style: t.style(14.5, FontWeight.w400, t.ink2),
              ),
              const SizedBox(height: 16),
              Text('Peso', style: t.style(13, FontWeight.w600, t.ink2)),
              const SizedBox(height: 6),
              HuTextField(
                controller: weightCtrl,
                prefixIcon: 'i-scale',
                suffixText: 'kg',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                hasError: weightErr,
              ),
              for (final (label, currentVal, options, onSelect) in [
                (
                  'Actividad',
                  act,
                  ['Poca', 'Normal', 'Mucha'],
                  (String v) => setSheetState(() => act = v),
                ),
                (
                  'Comida',
                  food,
                  ['Nada', 'Poco', 'Bien'],
                  (String v) => setSheetState(() => food = v),
                ),
                (
                  'Ánimo',
                  mood,
                  ['Decaído', tranquilLabel, 'Feliz'],
                  (String v) => setSheetState(() => mood = v),
                ),
              ]) ...[
                Text(label, style: t.style(13, FontWeight.w600, t.ink2)),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      for (final (idx, op) in options.indexed) ...[
                        if (idx > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _SegmentChoiceButton(
                            label: op,
                            selected: currentVal == op,
                            onTap: () => onSelect(op),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (mood == 'Decaído' || food == 'Nada')
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: HuInfoBox(
                    icon: 'i-info',
                    accent: HuAccent.sun,
                    text:
                        'Si sigue así más de 24 horas, agenda una consulta. Si notas algo grave, usa Emergencia.',
                  ),
                ),
              HuButton(
                label: 'Guardar',
                onPressed: () {
                  final raw = double.tryParse(
                        weightCtrl.text.replaceAll(',', '.').trim(),
                      ) ??
                      -1;
                  final w = (raw * 10).round() / 10.0;
                  if (!(w > 0 && w < 150)) {
                    setSheetState(() => weightErr = true);
                    getIt<Toaster>().show('Escribe un peso válido.');
                    return;
                  }
                  context.read<PetsBloc>().add(PetDailyLogged(
                        petId: pet.id,
                        weightKg: w,
                        activityLevel: act,
                        appetite: food,
                        mood: mood,
                      ));
                  Navigator.of(ctx).pop();
                  getIt<Toaster>().show(
                    'Listo. Guardamos cómo está ${pet.name} hoy.',
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

class _SegmentChoiceButton extends StatelessWidget {
  const _SegmentChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return HuPressable(
      onTap: onTap,
      selected: selected,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? t.tealSoft : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? t.teal : t.line,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: t.style(
            14.5,
            FontWeight.w600,
            selected ? t.tealDeep : t.ink2,
          ),
        ),
      ),
    );
  }
}

/// Pantalla 7: Mis mascotas (`s-pets`).
class PetsListPage extends StatelessWidget {
  const PetsListPage({super.key});

  void _openPetNew(BuildContext context, bool isFirst) {
    context.read<PetWizardBloc>().add(PetWizardStarted(isFirstPet: isFirst));
    context.push('/pet/new');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final pets = context.watch<PetsBloc>().state.pets;

    return HuScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 62), 22, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mis mascotas', style: t.h1Large),
                HuHeaderCircleButton(
                  icon: 'i-plus',
                  label: 'Agregar mascota',
                  fillColor: t.teal,
                  iconColor: Colors.white,
                  onTap: () => _openPetNew(context, pets.isEmpty),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pets.isEmpty)
              Center(
                child: EmptyState(
                  artKey: 'a-dog',
                  title: 'Aún no hay mascotas',
                  subtitle:
                      'Agrega a tu primera mascota para guardar su ficha, vacunas y citas.',
                  buttonLabel: 'Agregar mascota',
                  onButtonPressed: () => _openPetNew(context, true),
                ),
              )
            else ...[
              for (final p in pets)
                Builder(
                  builder: (_) {
                    final score = PetHealthRules.healthScore(today, p);
                    final (hl, hc) = PetHealthRules.healthTag(score);
                    final lateCount = p.vaccines
                        .where((v) =>
                            PetHealthRules.vaccineState(today, v) ==
                            VaccineState.late)
                        .length;
                    final nextCount = p.vaccines
                        .where((v) =>
                            PetHealthRules.vaccineState(today, v) ==
                            VaccineState.next)
                        .length;
                    return HuCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        context
                            .read<PetsBloc>()
                            .add(PetSelected(p.id, tab: 'vax'));
                        context.push('/pet');
                      },
                      child: Row(
                        children: [
                          PetAvatar(
                            artKey: p.artKey,
                            accent: p.accent,
                            size: 84,
                            radius: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: t.style(21, FontWeight.w600, t.ink, 1.1),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${p.breed} · ${HuFormat.ageOf(today, p.birthDate)} · ${p.weightKg} kg',
                                  style: t.style(13, FontWeight.w600, t.ink2),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    StatusTag(hl, accent: hc),
                                    if (lateCount > 0)
                                      StatusTag(
                                        '$lateCount vencida${lateCount > 1 ? 's' : ''}',
                                        accent: HuAccent.bad,
                                      )
                                    else if (nextCount > 0)
                                      StatusTag(
                                        '$nextCount próxima${nextCount > 1 ? 's' : ''}',
                                        accent: HuAccent.sun,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          HealthRing(
                            score: score,
                            size: 52,
                            strokeWidth: 4.5,
                            color: score >= 85
                                ? t.ok
                                : score >= 70
                                    ? t.sun
                                    : t.bad,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              AddPetCard(
                label: 'Agregar otra mascota',
                horizontal: true,
                onTap: () => _openPetNew(context, false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pantalla 8: Perfil de mascota (`s-pet`, «Chat & Health Tracker»).
class PetProfilePage extends StatefulWidget {
  const PetProfilePage({super.key});

  @override
  State<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage> {
  final Set<int> _expandedHistory = {};

  static const Map<String, (String label, String dqIcon, Color color)>
      _reminderCat = {
    'med': ('Medicamento', 'pill', Color(0xFFF2775E)),
    'dew': ('Antiparasitario', 'pill', Color(0xFF8B7BD8)),
    'vac': ('Vacunación', 'syringe', Color(0xFF1F9E8F)),
    'bath': ('Higiene', 'syringe', Color(0xFF3D9BE9)),
    'food': ('Compras', 'syringe', Color(0xFFF5B94A)),
  };

  void _openEditPetSheet(BuildContext context, Pet pet, int petIndex) {
    final nameCtrl = TextEditingController(text: pet.name);
    final breedCtrl = TextEditingController(text: pet.breed);
    final chipCtrl = TextEditingController(text: pet.chip);
    showHuSheet(
      context,
      builder: (ctx) {
        final t = ctx.hu;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Editar ficha',
              style: t.style(23, FontWeight.w600, t.ink, 1.15),
            ),
            const SizedBox(height: 14),
            Text('Nombre', style: t.style(13, FontWeight.w600, t.ink2)),
            const SizedBox(height: 6),
            HuTextField(controller: nameCtrl),
            Text('Raza', style: t.style(13, FontWeight.w600, t.ink2)),
            const SizedBox(height: 6),
            HuTextField(controller: breedCtrl),
            Text('Microchip', style: t.style(13, FontWeight.w600, t.ink2)),
            const SizedBox(height: 6),
            HuTextField(controller: chipCtrl, prefixIcon: 'i-chip'),
            const SizedBox(height: 4),
            HuButton(
              label: 'Guardar cambios',
              onPressed: () {
                final n = nameCtrl.text.trim();
                if (n.length < 2) {
                  getIt<Toaster>().show(
                    'El nombre necesita al menos 2 letras.',
                  );
                  return;
                }
                context.read<PetsBloc>().add(PetUpdated(
                      petId: pet.id,
                      name: n,
                      breed: breedCtrl.text.trim(),
                      chip: chipCtrl.text.trim(),
                    ));
                Navigator.of(ctx).pop();
                getIt<Toaster>().show('Ficha actualizada.');
              },
            ),
            Center(
              child: HuButton(
                label: 'Eliminar mascota',
                variant: HuButtonVariant.link,
                customTextColor: t.bad,
                onPressed: () {
                  final petsBloc = context.read<PetsBloc>();
                  petsBloc.add(PetDeleted(pet.id));
                  Navigator.of(ctx).pop();
                  context.go('/pets');
                  getIt<Toaster>().show(
                    'Eliminaste la ficha de ${pet.name}.',
                    actionLabel: 'Deshacer',
                    onAction: () {
                      petsBloc.add(PetRestored(index: petIndex, pet: pet));
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _openAddVaccineSheet(BuildContext context, Pet pet, DateTime today) {
    final nameCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: HuFormat.iso(today));
    int repeatDays = 365;

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
                  'Agregar registro',
                  style: t.style(23, FontWeight.w600, t.ink, 1.15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Una vacuna o desparasitación que ya tiene ${pet.name}.',
                  style: t.style(14.5, FontWeight.w400, t.ink2),
                ),
                const SizedBox(height: 16),
                Text('Nombre', style: t.style(13, FontWeight.w600, t.ink2)),
                const SizedBox(height: 6),
                HuTextField(
                  controller: nameCtrl,
                  prefixIcon: 'i-syringe',
                  placeholder: 'Por ejemplo, Rabia',
                ),
                Text(
                  'Fecha en que se aplicó',
                  style: t.style(13, FontWeight.w600, t.ink2),
                ),
                const SizedBox(height: 6),
                HuTextField(
                  controller: dateCtrl,
                  prefixIcon: 'i-cal',
                  placeholder: 'AAAA-MM-DD',
                ),
                Text(
                  'Se repite cada',
                  style: t.style(13, FontWeight.w600, t.ink2),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _SegmentChoiceButton(
                        label: '6 meses',
                        selected: repeatDays == 182,
                        onTap: () => setSheetState(() => repeatDays = 182),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SegmentChoiceButton(
                        label: '1 año',
                        selected: repeatDays == 365,
                        onTap: () => setSheetState(() => repeatDays = 365),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                HuButton(
                  label: 'Guardar registro',
                  onPressed: () {
                    final n = nameCtrl.text.trim();
                    final d = dateCtrl.text.trim();
                    if (n.length < 2 || d.isEmpty) {
                      getIt<Toaster>().show('Completa el nombre y la fecha.');
                      return;
                    }
                    final appliedDt = HuFormat.fromIso(d);
                    final nextDue =
                        HuFormat.iso(HuFormat.addDays(appliedDt, repeatDays));
                    context.read<PetsBloc>().add(PetVaccineAdded(
                          petId: pet.id,
                          vaccine: Vaccine(
                            name: n,
                            appliedOn: d,
                            nextDue: nextDue,
                          ),
                        ));
                    Navigator.of(ctx).pop();
                    getIt<Toaster>().show('Registro agregado al carnet.');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openBook(BuildContext context, Pet pet, {String? typeId}) {
    final pets = context.read<PetsBloc>().state.pets;
    final appts = context.read<AppointmentsBloc>().state.appointments;
    context.read<BookingBloc>().add(BookingStarted(
          pets: pets,
          appointments: appts,
          petId: pet.id,
          typeId: typeId,
        ));
    context.push('/book');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final petsState = context.watch<PetsBloc>().state;
    final pet = petsState.selectedPet;
    if (pet == null) {
      return const PetsListPage();
    }
    final petIndex = petsState.pets.indexOf(pet);
    final chatState = context.watch<ChatBloc>().state;
    final remsState = context.watch<RemindersBloc>().state;

    // Hilo de chat con su vet
    ChatThread? thread;
    for (final th in chatState.threads) {
      if (th.who == 'vet' && th.refId == pet.vetId) {
        thread = th;
        break;
      }
    }
    thread ??= chatState.threads.where((th) => th.who == 'vet').firstOrNull;
    final vet = DemoData.vetById(thread?.refId ?? pet.vetId);
    final lastMsgs = thread != null
        ? thread.messages.takeLast3
        : const <ChatMessage>[];

    // Variación de peso
    final ws = pet.weightHistory;
    final wd = ws.length > 1
        ? ((ws.last - ws[ws.length - 2]) * 10).round() / 10.0
        : 0.0;
    final wdLabel =
        wd == 0 ? 'Estable' : '${wd > 0 ? '+' : ''}$wd kg';

    // Próximos recordatorios de la mascota (hasta 3)
    final petRems = remsState.reminders
        .where((r) => r.petId == pet.id && !r.done)
        .toList()
      ..sort((a, b) => '${a.date}${a.time}'.compareTo('${b.date}${b.time}'));

    return HuScaffold(
      topBar: HuTopBar(
        title: pet.name,
        centered: true,
        onBack: () => context.pop(),
        trailing: HuPressable(
          onTap: () => _openEditPetSheet(context, pet, petIndex),
          semanticLabel: 'Opciones de la mascota',
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: pet.accent.petAvatarRingBg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x731D2A44),
                  offset: Offset(0, 6),
                  blurRadius: 14,
                  spreadRadius: -6,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: HuArt(pet.artKey, width: 48, height: 48),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 124), 22, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Chat con su vet (.vchat)
            HuCard(
              radius: 22,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat con su vet',
                            style: t.style(18, FontWeight.w600, t.ink, 1.2),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2EB872),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'En línea',
                                style: t.style(14, FontWeight.w400, t.ink2),
                              ),
                            ],
                          ),
                        ],
                      ),
                      HuPressable(
                        onTap: () {
                          context.read<ChatBloc>().add(ChatThreadOpened(vet.id));
                          context.push('/chat');
                        },
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: t.teal,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Nuevo chat',
                            style: t.style(14, FontWeight.w500, Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  for (final m in lastMsgs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: m.fromMe
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: t.teal,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(6),
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      m.text,
                                      style: t.style(
                                        13.5,
                                        FontWeight.w400,
                                        Colors.white,
                                        1.45,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          m.time.contains(':')
                                              ? HuFormat.ampm(m.time)
                                              : m.time,
                                          style: t.style(
                                            11,
                                            FontWeight.w400,
                                            Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const HuIcon(
                                          'i-check',
                                          size: 14,
                                          color: Colors.white,
                                          strokeWidth: 2.4,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HuPersonAvatar(vet.avatarKey, size: 44),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 260),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F5F7),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vet.name,
                                          style: t.style(
                                            12.5,
                                            FontWeight.w400,
                                            t.ink2,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          m.text,
                                          style: t.style(
                                            13.5,
                                            FontWeight.w400,
                                            t.ink,
                                            1.45,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          m.time.contains(':')
                                              ? HuFormat.ampm(m.time)
                                              : m.time,
                                          style: t.style(
                                            11,
                                            FontWeight.w400,
                                            t.ink3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                ],
              ),
            ),

            // 2. Resumen de salud / Registrar (.hov)
            HuCard(
              margin: const EdgeInsets.only(top: 16),
              radius: 22,
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
              child: Column(
                children: [
                  HuSectionHeader(
                    'Resumen de salud',
                    actionLabel: 'Registrar',
                    onAction: () => openPetDailyLogSheet(context, pet),
                    topMargin: 16,
                    bottomMargin: 14,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: HealthTile(
                          dqIcon: 'paw',
                          iconColor: t.teal,
                          label: 'Actividad',
                          value: '${pet.activity}%',
                          status: pet.activity >= 70
                              ? 'Buena'
                              : pet.activity >= 45
                                  ? 'Normal'
                                  : 'Baja',
                          progress: pet.activity / 100.0,
                          barColor: t.teal,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: HealthTile(
                          dqIcon: 'weight',
                          iconColor: t.lav,
                          label: 'Peso',
                          value: '${pet.weightKg}',
                          unit: ' kg',
                          status: wdLabel,
                          progress: 0.70,
                          barColor: t.lav,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: HealthTile(
                          dqIcon: 'drop',
                          iconColor: t.sky,
                          label: 'Hidratación',
                          value: '${pet.hydration}%',
                          status: pet.hydration >= 70 ? 'Buena' : 'Baja',
                          progress: pet.hydration / 100.0,
                          barColor: t.sky,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: HealthTile(
                          dqIcon: 'smile',
                          iconColor: const Color(0xFFF5A524),
                          label: 'Ánimo',
                          value: pet.mood,
                          status: '',
                          progress: pet.mood == 'Feliz'
                              ? 0.55
                              : pet.mood == 'Decaído'
                                  ? 0.20
                                  : 0.45,
                          barColor: const Color(0xFFF28C3C),
                          smallValueText: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Próximos recordatorios / Ver todo (.hov)
            HuCard(
              margin: const EdgeInsets.only(top: 16),
              radius: 22,
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HuSectionHeader(
                    'Próximos recordatorios',
                    actionLabel: 'Ver todo',
                    onAction: () => context.push('/reminders'),
                    topMargin: 16,
                    bottomMargin: 14,
                  ),
                  if (petRems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        'No hay recordatorios pendientes.',
                        style: t.style(14.5, FontWeight.w400, t.ink2),
                      ),
                    )
                  else
                    for (final r in petRems.take(3))
                      Builder(
                        builder: (_) {
                          final cat =
                              _reminderCat[r.type] ?? _reminderCat['vac']!;
                          final dt = HuFormat.fromIso(r.date);
                          return HuPressable(
                            onTap: () => context.push('/reminders'),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: t.border),
                              ),
                              child: Row(
                                children: [
                                  HuDqIcon(cat.$2, color: cat.$3, size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.$1,
                                          style: t.style(
                                            15,
                                            FontWeight.w500,
                                            t.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          r.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: t.style(
                                            13,
                                            FontWeight.w400,
                                            t.ink2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${dt.day} ${HuFormat.mon[dt.month - 1]} ${dt.year}',
                                        style: t.style(
                                          13,
                                          FontWeight.w400,
                                          t.ink,
                                        ),
                                      ),
                                      Text(
                                        HuFormat.ampm(r.time),
                                        style: t.style(
                                          13,
                                          FontWeight.w400,
                                          t.ink2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  HuIcon('i-chev', size: 18, color: t.ink3),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),

            // 4. Pestañas segmentadas: Vacunas / Historial / Ficha (.tabs2)
            Padding(
              padding: const EdgeInsets.only(top: 22, bottom: 4),
              child: SegmentedTabs<String>(
                items: const [
                  ('vax', 'Vacunas'),
                  ('hist', 'Historial'),
                  ('data', 'Ficha'),
                ],
                selected: petsState.activeTab,
                onChanged: (tab) =>
                    context.read<PetsBloc>().add(PetTabChanged(tab)),
              ),
            ),

            // Contenido de la pestaña activa
            if (petsState.activeTab == 'vax')
              _buildVaccinesTab(context, pet, today)
            else if (petsState.activeTab == 'hist')
              _buildHistoryTab(context, pet)
            else
              _buildDataTab(context, pet, vet),

            const SizedBox(height: 18),
            HuButton(
              label: 'Reservar cita',
              icon: 'i-cal',
              onPressed: () => _openBook(context, pet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinesTab(BuildContext context, Pet pet, DateTime today) {
    final t = context.hu;
    final list = [...pet.vaccines]
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
    int countByState(VaccineState st) => pet.vaccines
        .where((v) => PetHealthRules.vaccineState(today, v) == st)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 14),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusTag('${countByState(VaccineState.ok)} al día',
                  accent: HuAccent.ok),
              StatusTag('${countByState(VaccineState.next)} próximas',
                  accent: HuAccent.sun),
              StatusTag('${countByState(VaccineState.late)} vencidas',
                  accent: HuAccent.bad),
            ],
          ),
        ),
        if (list.isEmpty)
          EmptyState(
            artKey: pet.artKey,
            title: 'Sin registros todavía',
            subtitle:
                'Agrega las vacunas que ya tiene para que te avisemos de las próximas.',
          )
        else
          Column(
            children: [
              for (final (idx, v) in list.indexed)
                Builder(
                  builder: (_) {
                    final st = PetHealthRules.vaccineState(today, v);
                    final n = HuFormat.daysFrom(today, v.nextDue);
                    final (tagLabel, tagAccent, dotColor, dotBg) = switch (st) {
                      VaccineState.ok => (
                          'Al día',
                          HuAccent.ok,
                          t.teal,
                          t.tealSoft,
                        ),
                      VaccineState.next => (
                          n == 0 ? 'Hoy' : 'En $n días',
                          HuAccent.sun,
                          t.sun,
                          t.sunSoft,
                        ),
                      VaccineState.late => (
                          'Vencida hace ${-n} días',
                          HuAccent.bad,
                          t.bad,
                          t.badSoft,
                        ),
                    };
                    final isFirst = idx == 0;
                    final isLast = idx == list.length - 1;
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 26,
                            child: Column(
                              children: [
                                Container(
                                  width: 2,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color:
                                        isFirst ? Colors.transparent : t.line,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: dotBg,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: dotColor.withValues(alpha: 0.35),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: HuIcon(
                                    'i-paw',
                                    size: 14,
                                    color: dotColor,
                                    fill: dotColor,
                                    strokeWidth: 0,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    decoration: BoxDecoration(
                                      color:
                                          isLast ? Colors.transparent : t.line,
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: HuCard(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          v.name,
                                          style: t.style(
                                            15,
                                            FontWeight.w600,
                                            t.ink,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StatusTag(tagLabel, accent: tagAccent),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${v.isDeworming ? 'Desparasitación' : 'Vacuna'} · aplicada el ${HuFormat.fDate(v.appliedOn)}',
                                    style: t.style(
                                      13,
                                      FontWeight.w600,
                                      t.ink2,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Próxima: ',
                                      style: t.style(
                                        13,
                                        FontWeight.w600,
                                        t.ink2,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: HuFormat.fDate(v.nextDue),
                                          style: t.style(
                                            13,
                                            FontWeight.w700,
                                            t.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
        const SizedBox(height: 6),
        HuButton(
          label: 'Reservar vacunación',
          icon: 'i-syringe',
          onPressed: () => _openBook(context, pet, typeId: 'vac'),
        ),
        const SizedBox(height: 10),
        HuButton(
          label: 'Agregar registro',
          icon: 'i-plus',
          variant: HuButtonVariant.soft,
          onPressed: () => _openAddVaccineSheet(context, pet, today),
        ),
        Center(
          child: HuButton(
            label: 'Descargar carnet en PDF',
            variant: HuButtonVariant.link,
            onPressed: () =>
                getIt<Toaster>().show('Descargando el carnet de vacunas.'),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context, Pet pet) {
    final t = context.hu;
    final sorted = [...pet.history]..sort((a, b) => b.date.compareTo(a.date));
    if (sorted.isEmpty) {
      return EmptyState(
        artKey: pet.artKey,
        title: 'Sin historial',
        subtitle: 'Aquí verás cada consulta, diagnóstico y receta.',
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          for (final (idx, entry) in sorted.indexed)
            Builder(
              builder: (_) {
                final open = _expandedHistory.contains(idx);
                final vetSuffix = entry.vetId != null
                    ? ' · ${DemoData.vetById(entry.vetId!).name}'
                    : '';
                return HuCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  onTap: () {
                    setState(() {
                      if (!open) {
                        _expandedHistory.add(idx);
                      } else {
                        _expandedHistory.remove(idx);
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBox(
                            icon: entry.vetId != null ? 'i-steth' : 'i-scissors',
                            accent: HuAccent.teal,
                            size: 42,
                            radius: 13,
                            iconSize: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.type,
                                  style: t.style(15, FontWeight.w600, t.ink),
                                ),
                                Text(
                                  '${HuFormat.fDate(entry.date)}$vetSuffix',
                                  style: t.style(12.5, FontWeight.w600, t.ink2),
                                ),
                              ],
                            ),
                          ),
                          Transform.rotate(
                            angle: open ? 1.5708 : 0,
                            child: HuIcon('i-chev', size: 20, color: t.ink3),
                          ),
                        ],
                      ),
                      if (open) ...[
                        const SizedBox(height: 12),
                        Divider(color: t.line, height: 1),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            text: 'Diagnóstico: ',
                            style: t.style(13.5, FontWeight.w600, t.ink),
                            children: [
                              TextSpan(
                                text: entry.diagnosis,
                                style: t.style(13.5, FontWeight.w400, t.ink2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            text: 'Indicaciones: ',
                            style: t.style(13.5, FontWeight.w600, t.ink),
                            children: [
                              TextSpan(
                                text: entry.treatment,
                                style: t.style(13.5, FontWeight.w400, t.ink2),
                              ),
                            ],
                          ),
                        ),
                        if (entry.documentLabel != null) ...[
                          const SizedBox(height: 8),
                          HuPressable(
                            onTap: () => getIt<Toaster>().show(
                              'Abriendo el documento en PDF.',
                            ),
                            child: StatusTag(
                              'Ver ${entry.documentLabel!.toLowerCase()}',
                              icon: 'i-doc',
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDataTab(BuildContext context, Pet pet, Vet vet) {
    final t = context.hu;
    final ws = pet.weightHistory;
    final rows = [
      ('i-paw', 'Raza', pet.breed),
      ('i-cake', 'Nacimiento', HuFormat.fDate(pet.birthDate)),
      ('i-chip', 'Microchip', pet.chip),
      ('i-shield', 'Esterilizado', pet.neutered ? 'Sí' : 'No'),
      (
        'i-alert',
        'Alergias',
        pet.allergies.isNotEmpty ? pet.allergies.join(', ') : 'Ninguna',
      ),
      ('i-steth', 'Su vet', vet.name),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HuSectionHeader(
          'Peso',
          trailingText:
              'Últimos ${ws.length} ${ws.length == 1 ? 'registro' : 'meses'}',
        ),
        WeightChart(weights: ws),
        const HuSectionHeader('Datos'),
        HuCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final (idx, r) in rows.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: idx == rows.length - 1
                        ? null
                        : Border(bottom: BorderSide(color: t.line)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: HuIcon(r.$1, size: 20, color: t.ink3),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        r.$2,
                        style: t.style(14.5, FontWeight.w600, t.ink2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r.$3,
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
      ],
    );
  }
}

extension _ListLast3<T> on List<T> {
  List<T> get takeLast3 => length <= 3 ? this : sublist(length - 3);
}

/// Pantalla 5: Wizard de 5 pasos «Nueva mascota» (`s-petnew`).
class PetNewWizardPage extends StatefulWidget {
  const PetNewWizardPage({super.key});

  @override
  State<PetNewWizardPage> createState() => _PetNewWizardPageState();
}

class _PetNewWizardPageState extends State<PetNewWizardPage> {
  final _nameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _birthCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final wiz = context.watch<PetWizardBloc>().state;
    final petsCount = context.watch<PetsBloc>().state.pets.length;

    return HuScaffold(
      topBar: HuTopBar(
        title: wiz.step == 5 ? '¡Listo!' : 'Nueva mascota',
        subtitle: wiz.step < 5 ? 'Paso ${wiz.step} de 4' : null,
        hideBack: wiz.step == 5,
        onBack: () {
          if (wiz.step > 1) {
            context.read<PetWizardBloc>().add(const PetWizardBackPressed());
          } else {
            context.pop();
          }
        },
        trailing: HuHeaderCircleButton(
          icon: 'i-x',
          label: 'Cerrar',
          ghost: true,
          onTap: () => context.go('/home'),
        ),
      ),
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              t.bg.withValues(alpha: 0.0),
              t.bg,
            ],
          ),
        ),
        child: HuButton(
          label: wiz.step == 4
              ? 'Crear ficha'
              : wiz.step == 5
                  ? 'Ver la ficha de ${wiz.name.trim()}'
                  : 'Continuar',
          onPressed: wiz.isStepValid
              ? () {
                  if (wiz.step == 4) {
                    context.read<PetWizardBloc>().add(
                          PetWizardNextPressed(existingPetCount: petsCount),
                        );
                    return;
                  }
                  if (wiz.step == 5) {
                    final created = wiz.createdPet;
                    if (created != null) {
                      context.read<PetsBloc>().add(PetAdded(created));
                    }
                    context.go('/home');
                    context.push('/pet');
                    return;
                  }
                  context.read<PetWizardBloc>().add(
                        PetWizardNextPressed(existingPetCount: petsCount),
                      );
                }
              : null,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, HuLayout.top(context, 118), 0, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de progreso .wz .bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 6,
                  width: double.infinity,
                  child: ColoredBox(
                    color: t.line,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (wiz.step / 5.0).clamp(0.0, 1.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: t.teal,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              child: switch (wiz.step) {
                1 => _buildStep1(context, wiz),
                2 => _buildStep2(context, wiz),
                3 => _buildStep3(context, wiz, today),
                4 => _buildStep4(context, wiz),
                _ => _buildStep5(context, wiz, today),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(BuildContext context, PetWizardState wiz) {
    final t = context.hu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wiz.isFirstPet
              ? 'Cuéntanos de tu mascota'
              : '¿Quién se une a la familia?',
          style: t.h1Large,
        ),
        const SizedBox(height: 4),
        Text(
          'Elige la especie para mostrarte lo que le corresponde.',
          style: t.style(14.5, FontWeight.w400, t.ink2),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            for (final (idx, sp) in PetSpecies.values.indexed) ...[
              if (idx > 0) const SizedBox(width: 12),
              Expanded(
                child: HuPressable(
                  onTap: () => context
                      .read<PetWizardBloc>()
                      .add(PetWizardSpeciesSelected(sp)),
                  selected: wiz.species == sp,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: wiz.species == sp ? t.tealSoft : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: wiz.species == sp ? t.teal : t.line,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PetAvatar(
                          artKey: sp.defaultArt,
                          accent: sp.defaultAccent,
                          size: 84,
                          circular: true,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sp.label,
                          style: t.style(15, FontWeight.w600, t.ink),
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
    );
  }

  Widget _buildStep2(BuildContext context, PetWizardState wiz) {
    final t = context.hu;
    if (_nameCtrl.text != wiz.name) {
      _nameCtrl.value = TextEditingValue(
        text: wiz.name,
        selection: TextSelection.collapsed(offset: wiz.name.length),
      );
    }
    const arts = [
      ('a-dog', HuAccent.teal),
      ('a-cat', HuAccent.coral),
      ('a-bunny', HuAccent.lav),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('¿Cómo se llama?', style: t.h1Large),
        const SizedBox(height: 4),
        Text(
          'Y elige una imagen. Luego puedes subir una foto real.',
          style: t.style(14.5, FontWeight.w400, t.ink2),
        ),
        const SizedBox(height: 20),
        Text('Nombre', style: t.style(13, FontWeight.w600, t.ink2)),
        const SizedBox(height: 6),
        HuTextField(
          controller: _nameCtrl,
          prefixIcon: 'i-paw',
          placeholder: 'Por ejemplo, Rocky',
          onChanged: (v) =>
              context.read<PetWizardBloc>().add(PetWizardNameChanged(v)),
        ),
        const SizedBox(height: 8),
        Text('Imagen', style: t.style(13, FontWeight.w600, t.ink2)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final (idx, item) in arts.indexed)
              HuPressable(
                onTap: () => context
                    .read<PetWizardBloc>()
                    .add(PetWizardArtSelected(item.$1)),
                semanticLabel: 'Imagen ${idx + 1}',
                selected: wiz.effectiveArtKey == item.$1,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: item.$2.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: wiz.effectiveArtKey == item.$1
                          ? t.teal
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: wiz.effectiveArtKey == item.$1
                        ? [BoxShadow(color: t.tealSoft, spreadRadius: 3)]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: HuArt(item.$1, width: 64, height: 64),
                ),
              ),
            HuPressable(
              onTap: () =>
                  getIt<Toaster>().show('Aquí se abre la cámara o tu galería.'),
              semanticLabel: 'Subir foto',
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.mint, width: 2),
                ),
                alignment: Alignment.center,
                child: HuIcon('i-camera', size: 22, color: t.teal),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep3(
    BuildContext context,
    PetWizardState wiz,
    DateTime today,
  ) {
    final t = context.hu;
    if (_breedCtrl.text != wiz.breed) {
      _breedCtrl.value = TextEditingValue(
        text: wiz.breed,
        selection: TextSelection.collapsed(offset: wiz.breed.length),
      );
    }
    if (_birthCtrl.text != wiz.birthDate) {
      _birthCtrl.value = TextEditingValue(
        text: wiz.birthDate,
        selection: TextSelection.collapsed(offset: wiz.birthDate.length),
      );
    }
    final sp = wiz.species ?? PetSpecies.dog;
    final allBreeds = DemoData.breeds[sp] ?? const [];
    final filteredBreeds = allBreeds
        .where((b) =>
            wiz.breed.isEmpty ||
            HuFormat.norm(b).contains(HuFormat.norm(wiz.breed)))
        .take(8)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Un poco más sobre ${wiz.name.trim()}', style: t.h1Large),
        const SizedBox(height: 4),
        Text(
          'Esto ayuda a su veterinario y a calcular sus vacunas.',
          style: t.style(14.5, FontWeight.w400, t.ink2),
        ),
        const SizedBox(height: 20),
        Text('Raza', style: t.style(13, FontWeight.w600, t.ink2)),
        const SizedBox(height: 6),
        HuTextField(
          controller: _breedCtrl,
          prefixIcon: 'i-search',
          placeholder: 'Busca o escribe la raza',
          onChanged: (v) =>
              context.read<PetWizardBloc>().add(PetWizardBreedChanged(v)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final b in filteredBreeds)
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 14),
                  child: HuChip(
                    label: b,
                    selected: wiz.breed == b,
                    onTap: () {
                      _breedCtrl.text = b;
                      context
                          .read<PetWizardBloc>()
                          .add(PetWizardBreedChanged(b));
                    },
                  ),
                ),
            ],
          ),
        ),
        Text(
          'Fecha de nacimiento (aproximada)',
          style: t.style(13, FontWeight.w600, t.ink2),
        ),
        const SizedBox(height: 6),
        HuTextField(
          controller: _birthCtrl,
          prefixIcon: 'i-cake',
          placeholder: 'AAAA-MM-DD',
          onChanged: (v) =>
              context.read<PetWizardBloc>().add(PetWizardBirthDateChanged(v)),
          suffix: HuPressable(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: today.subtract(const Duration(days: 365)),
                firstDate: DateTime(2005),
                lastDate: today,
              );
              if (picked != null && context.mounted) {
                final iso = HuFormat.iso(picked);
                _birthCtrl.text = iso;
                context
                    .read<PetWizardBloc>()
                    .add(PetWizardBirthDateChanged(iso));
              }
            },
            child: HuIcon('i-cal', size: 20, color: t.teal),
          ),
        ),
        Text('Sexo', style: t.style(13, FontWeight.w600, t.ink2)),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final (idx, sx) in ['Macho', 'Hembra'].indexed) ...[
              if (idx > 0) const SizedBox(width: 10),
              Expanded(
                child: _SegmentChoiceButton(
                  label: sx,
                  selected: wiz.sex == sx,
                  onTap: () => context
                      .read<PetWizardBloc>()
                      .add(PetWizardSexSelected(sx)),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStep4(BuildContext context, PetWizardState wiz) {
    final t = context.hu;
    if (_weightCtrl.text != wiz.weightInput) {
      _weightCtrl.value = TextEditingValue(
        text: wiz.weightInput,
        selection: TextSelection.collapsed(offset: wiz.weightInput.length),
      );
    }
    const allergiesList = [
      'Pollo',
      'Res',
      'Granos',
      'Lácteos',
      'Polen',
      'Pulgas',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Su salud', style: t.h1Large),
        const SizedBox(height: 4),
        Text(
          'Puedes completarlo luego desde su ficha.',
          style: t.style(14.5, FontWeight.w400, t.ink2),
        ),
        const SizedBox(height: 20),
        Text('Peso', style: t.style(13, FontWeight.w600, t.ink2)),
        const SizedBox(height: 6),
        HuTextField(
          controller: _weightCtrl,
          prefixIcon: 'i-scale',
          placeholder: '0.0',
          suffixText: 'kg',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) =>
              context.read<PetWizardBloc>().add(PetWizardWeightChanged(v)),
        ),
        Text(
          '¿Está esterilizado?',
          style: t.style(13, FontWeight.w600, t.ink2),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _SegmentChoiceButton(
                label: 'Sí',
                selected: wiz.neutered == true,
                onTap: () => context
                    .read<PetWizardBloc>()
                    .add(const PetWizardNeuteredSelected(true)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SegmentChoiceButton(
                label: 'No',
                selected: wiz.neutered == false,
                onTap: () => context
                    .read<PetWizardBloc>()
                    .add(const PetWizardNeuteredSelected(false)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Alergias conocidas',
          style: t.style(13, FontWeight.w600, t.ink2),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in allergiesList)
              HuChip(
                label: a,
                selected: wiz.allergies.contains(a),
                onTap: () => context
                    .read<PetWizardBloc>()
                    .add(PetWizardAllergyToggled(a)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep5(
    BuildContext context,
    PetWizardState wiz,
    DateTime today,
  ) {
    final t = context.hu;
    final p = wiz.createdPet;
    if (p == null) return const SizedBox.shrink();
    final rows = [
      ('i-paw', 'Raza', p.breed),
      ('i-cake', 'Edad', HuFormat.ageOf(today, p.birthDate)),
      ('i-scale', 'Peso', '${p.weightKg} kg'),
    ];
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: p.accent.bg,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 10),
          ),
          clipBehavior: Clip.antiAlias,
          child: HuArt(p.artKey, width: 200, height: 200),
        ),
        const SizedBox(height: 22),
        Text(
          '¡Bienvenido, ${p.name}!',
          textAlign: TextAlign.center,
          style: t.h1Large,
        ),
        const SizedBox(height: 4),
        Text(
          'Ya creamos su ficha. Te avisaremos cuando le toque cada vacuna.',
          textAlign: TextAlign.center,
          style: t.style(14.5, FontWeight.w400, t.ink2),
        ),
        const SizedBox(height: 20),
        HuCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (final (idx, r) in rows.indexed)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: idx == rows.length - 1
                        ? null
                        : Border(bottom: BorderSide(color: t.line)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: HuIcon(r.$1, size: 20, color: t.ink3),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        r.$2,
                        style: t.style(14.5, FontWeight.w600, t.ink2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r.$3,
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
      ],
    );
  }
}
