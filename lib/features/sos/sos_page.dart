import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/di.dart';
import '../../core/data/demo_data.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../../core/widgets/google_map_view.dart';
import '../../core/widgets/toaster.dart';

/// Pantalla 29: Emergencia (`s-sos`).
class SosPage extends StatefulWidget {
  const SosPage({super.key});

  @override
  State<SosPage> createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  static const _signs = [
    'Le cuesta respirar o tiene las encías azuladas o muy pálidas',
    'Sangrado que no para, o un golpe fuerte',
    'Convulsiones o pérdida del conocimiento',
    'Comió algo tóxico: chocolate, uvas, medicinas, veneno',
    'Vómitos o diarrea con sangre, o el abdomen hinchado y duro',
    'No puede orinar o hace mucho esfuerzo',
  ];

  static const _tips = [
    'Mantén la calma y muévelo con cuidado',
    'No le des medicinas para personas',
    'Si comió algo tóxico, lleva el envase o una foto',
    'Llama antes para que lo estén esperando',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final h24Clinic = DemoData.clinics.firstWhere((c) => c.is24h);
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return HuScaffold(
      showVeil: false,
      lightStatusBar: true,
      topBar: HuTopBar(
        title: '',
        clear: true,
        onBack: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera roja .sosh
            Container(
              padding: EdgeInsets.fromLTRB(
                22,
                HuLayout.top(context, 110),
                22,
                26,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF06A5C), Color(0xFFD9483B)],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: -82,
                    top: -70,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 0,
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (context, _) {
                          final v1 = disableAnim ? 0.3 : _pulseCtrl.value;
                          final v2 =
                              disableAnim ? 0.7 : (_pulseCtrl.value + 0.5) % 1.0;
                          return Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              for (final v in [v1, v2])
                                Transform.scale(
                                  scale: 1.0 + 0.9 * v,
                                  child: Opacity(
                                    opacity: (0.8 * (1.0 - v)).clamp(0.0, 1.0),
                                    child: Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: HuIcon(
                                  'i-phone',
                                  size: 28,
                                  color: t.bad,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¿Es una emergencia?',
                        style: t.style(30, FontWeight.w600, Colors.white, 1.1),
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          'Llama de inmediato y ve a la clínica 24 horas más cercana. No esperes respuesta por chat.',
                          style: t.style(
                            14.5,
                            FontWeight.w600,
                            Colors.white.withValues(alpha: 0.92),
                            1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      HuPressable(
                        onTap: () => getIt<Toaster>().show(
                          'Llamando al Hospital Veterinario 24 h…',
                        ),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                offset: Offset(0, 16),
                                blurRadius: 28,
                                spreadRadius: -16,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HuIcon('i-phone', size: 20, color: t.bad),
                              const SizedBox(width: 10),
                              Text(
                                'Llamar al ${h24Clinic.phone}',
                                style: t.style(16, FontWeight.w600, t.bad),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HuSectionHeader('La más cercana'),
                  HuCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        GoogleMapView(
                          height: 130,
                          singlePinColor: t.bad,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    h24Clinic.name,
                                    style: t.style(15, FontWeight.w700, t.ink),
                                  ),
                                  Text(
                                    '${h24Clinic.address} · ${h24Clinic.km} km · unos 12 min en auto',
                                    style: t.style(
                                      13,
                                      FontWeight.w600,
                                      t.ink2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            HuButton(
                              label: 'Ir',
                              icon: 'i-map',
                              small: true,
                              expand: false,
                              onPressed: () => getIt<Toaster>()
                                  .show('Abriendo la ruta más rápida.'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const HuSectionHeader('Ve ya si notas'),
                  HuCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        for (final (idx, s) in _signs.indexed)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: idx == _signs.length - 1
                                  ? null
                                  : Border(bottom: BorderSide(color: t.line)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: HuIcon(
                                    'i-alert',
                                    size: 20,
                                    color: t.bad,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: t.style(
                                      14.5,
                                      FontWeight.w600,
                                      t.ink,
                                      1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const HuSectionHeader('Mientras llegas'),
                  HuCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        for (final (idx, tip) in _tips.indexed)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: idx == _tips.length - 1
                                  ? null
                                  : Border(bottom: BorderSide(color: t.line)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 1),
                                  child: HuIcon(
                                    'i-check',
                                    size: 20,
                                    color: t.teal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: t.style(
                                      14.5,
                                      FontWeight.w600,
                                      t.ink,
                                      1.4,
                                    ),
                                  ),
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
          ],
        ),
      ),
    );
  }
}

