import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/toaster.dart';
import '../pets/pets_bloc.dart';
import 'reminders_bloc.dart';

/// Pantalla 21: Recordatorios (`s-rem`).
class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  static const Map<String, (String icon, HuAccent accent, String label)> _rt = {
    'med': ('i-pill', HuAccent.coral, 'Medicina'),
    'vac': ('i-syringe', HuAccent.lav, 'Vacuna'),
    'dew': ('i-paw', HuAccent.sun, 'Antiparasitario'),
    'bath': ('i-scissors', HuAccent.teal, 'Higiene'),
    'food': ('i-bag', HuAccent.sky, 'Compras'),
  };

  void _openNewReminderSheet(BuildContext context, DateTime today) {
    final pets = context.read<PetsBloc>().state.pets;
    if (pets.isEmpty) {
      getIt<Toaster>().show('Primero agrega a tu mascota.');
      return;
    }
    String selectedType = 'med';
    String selectedPet = pets.first.id;
    String selectedRep = 'No se repite';
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: HuFormat.iso(today));
    final timeCtrl = TextEditingController(text: '20:00');
    bool titleErr = false;

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
                  'Nuevo recordatorio',
                  style: t.style(23, FontWeight.w600, t.ink, 1.15),
                ),
                const SizedBox(height: 12),
                Text('Tipo', style: t.style(13, FontWeight.w600, t.ink2)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _rt.entries)
                      HuChip(
                        label: entry.value.$3,
                        icon: entry.value.$1,
                        selected: selectedType == entry.key,
                        onTap: () =>
                            setSheetState(() => selectedType = entry.key),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Mascota', style: t.style(13, FontWeight.w600, t.ink2)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in pets)
                      HuChip(
                        label: p.name,
                        selected: selectedPet == p.id,
                        onTap: () => setSheetState(() => selectedPet = p.id),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Qué hay que hacer?',
                  style: t.style(13, FontWeight.w600, t.ink2),
                ),
                const SizedBox(height: 6),
                HuTextField(
                  controller: titleCtrl,
                  placeholder: 'Por ejemplo, pastilla de la alergia',
                  hasError: titleErr,
                ),
                Row(
                  children: [
                    Expanded(
                      child: HuTextField(
                        controller: dateCtrl,
                        placeholder: 'AAAA-MM-DD',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HuTextField(
                        controller: timeCtrl,
                        placeholder: 'HH:MM',
                      ),
                    ),
                  ],
                ),
                Text('Repetir', style: t.style(13, FontWeight.w600, t.ink2)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final rep in [
                      'No se repite',
                      'Diario',
                      'Semanal',
                      'Mensual',
                    ])
                      HuChip(
                        label: rep,
                        selected: selectedRep == rep,
                        onTap: () => setSheetState(() => selectedRep = rep),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                HuButton(
                  label: 'Guardar recordatorio',
                  onPressed: () {
                    final ttl = titleCtrl.text.trim();
                    if (ttl.length < 3 ||
                        dateCtrl.text.trim().isEmpty ||
                        timeCtrl.text.trim().isEmpty) {
                      setSheetState(() => titleErr = ttl.length < 3);
                      getIt<Toaster>().show(
                        'Escribe qué hay que hacer, la fecha y la hora.',
                      );
                      return;
                    }
                    context.read<RemindersBloc>().add(
                          ReminderAdded(
                            Reminder(
                              id: DateTime.now().millisecondsSinceEpoch,
                              type: selectedType,
                              petId: selectedPet,
                              title: ttl,
                              date: dateCtrl.text.trim(),
                              time: timeCtrl.text.trim(),
                              repeat: selectedRep,
                            ),
                          ),
                        );
                    Navigator.of(ctx).pop();
                    getIt<Toaster>().show(
                      'Recordatorio guardado. Te avisaremos a tiempo.',
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

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final today = getIt<Clock>().today;
    final rems = context.watch<RemindersBloc>().state.reminders;
    final petsState = context.watch<PetsBloc>().state;

    final pending = rems.where((r) => !r.done).toList();
    final late = pending
        .where((r) => HuFormat.daysFrom(today, r.date) < 0)
        .toList();
    final todayList = pending
        .where((r) => HuFormat.daysFrom(today, r.date) == 0)
        .toList();
    final next = pending
        .where((r) => HuFormat.daysFrom(today, r.date) > 0)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final done = rems.where((r) => r.done).toList();

    Widget buildSection(String title, List<Reminder> items) {
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 16, 2, 10),
            child: Text(title, style: t.style(13, FontWeight.w500, t.ink2)),
          ),
          for (final r in items)
            Builder(
              builder: (_) {
                final info = _rt[r.type] ?? _rt['med']!;
                final pet = petsState.byId(r.petId);
                final isLate = !r.done && HuFormat.daysFrom(today, r.date) < 0;
                final relStr = HuFormat.rel(today, r.date);
                return HuCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconBox(icon: info.$1, accent: info.$2),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title,
                              style: t
                                  .style(
                                    15,
                                    FontWeight.w600,
                                    r.done ? t.ink3 : t.ink,
                                  )
                                  .copyWith(
                                    decoration: r.done
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            RichText(
                              text: TextSpan(
                                text: pet != null ? '${pet.name} · ' : '',
                                style: t.style(12.5, FontWeight.w600, t.ink2),
                                children: [
                                  if (isLate)
                                    TextSpan(
                                      text: 'Vencido $relStr',
                                      style: t.style(
                                        12.5,
                                        FontWeight.w700,
                                        t.bad,
                                      ),
                                    )
                                  else
                                    TextSpan(
                                      text:
                                          '${HuFormat.cap(relStr)} · ${HuFormat.ampm(r.time)}',
                                    ),
                                  TextSpan(text: ' · ${r.repeat}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      HuPressable(
                        onTap: () {
                          final remsBloc = context.read<RemindersBloc>();
                          final willBeDone = !r.done;
                          remsBloc.add(ReminderToggled(r.id));
                          if (willBeDone) {
                            getIt<Toaster>().show(
                              'Hecho: ${r.title}.',
                              actionLabel: 'Deshacer',
                              onAction: () => remsBloc.add(
                                ReminderToggled(r.id, forceDone: false),
                              ),
                            );
                          }
                        },
                        semanticLabel: r.done
                            ? 'Marcar como pendiente'
                            : 'Marcar como hecho',
                        selected: r.done,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: r.done ? t.ok : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: r.done ? t.ok : t.line,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: r.done
                              ? const HuIcon(
                                  'i-check',
                                  size: 16,
                                  color: Colors.white,
                                  strokeWidth: 3,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      );
    }

    return HuScaffold(
      topBar: HuTopBar(
        title: 'Recordatorios',
        onBack: () => context.pop(),
        trailing: HuHeaderCircleButton(
          icon: 'i-plus',
          label: 'Nuevo recordatorio',
          fillColor: t.teal,
          iconColor: Colors.white,
          onTap: () => _openNewReminderSheet(context, today),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, HuLayout.top(context, 116), 22, 50),
        child: rems.isEmpty
            ? Center(
                child: EmptyState(
                  artKey: 'a-cat',
                  title: 'Sin recordatorios',
                  subtitle: 'Crea uno para medicinas, vacunas o el baño.',
                  buttonLabel: 'Nuevo recordatorio',
                  onButtonPressed: () => _openNewReminderSheet(context, today),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSection('Vencidos', late),
                  buildSection('Hoy', todayList),
                  buildSection('Próximos', next),
                  buildSection('Hechos', done),
                ],
              ),
      ),
    );
  }
}

