import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/format/hu_format.dart';
import '../../core/theme/hu_tokens.dart';
import '../../core/utils/clock.dart';
import '../../core/widgets/hu_icon.dart';
import '../../core/widgets/hu_widgets.dart';
import '../auth/session_bloc.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    super.key,
    this.initialPage = 0,
    this.clock = const SystemClock(),
  });

  final int initialPage;
  final Clock clock;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageCtrl;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialPage;
    _pageCtrl = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _finish() {
    context.read<SessionBloc>().add(const SessionOnboardingCompleted());
    context.go('/login');
  }

  void _next() {
    if (_currentIndex >= 2) {
      _finish();
    } else {
      final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
      if (disable) {
        _pageCtrl.jumpToPage(_currentIndex + 1);
      } else {
        _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final isLast = _currentIndex == 2;
    final monthName = HuFormat.cap(HuFormat.monLong[widget.clock.today.month - 1]);

    return HuScaffold(
      showVeil: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageCtrl,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            children: [
              _SlideView(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFD9F3EE), Color(0xFFBFEDE6), Color(0xFFE8F7F3)],
                ),
                titlePart1: 'Todo sobre tu mascota,\n',
                titleCoral: 'en un lugar',
                subtitle: 'Su ficha, sus vacunas y su historial, siempre a mano.',
                illustration: _Slide1Art(active: _currentIndex == 0),
              ),
              _SlideView(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE3F1FC), Color(0xFFEEEBFB), Color(0xFFF4FAF8)],
                ),
                titlePart1: 'Citas con su vet\n',
                titleCoral: 'en un minuto',
                subtitle: 'Elige motivo, veterinario y hora. Te recordamos todo.',
                illustration: _Slide2Art(
                  active: _currentIndex == 1,
                  monthName: monthName,
                ),
              ),
              _SlideView(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFDE8E3), Color(0xFFFEF3DC), Color(0xFFF4FAF8)],
                ),
                titlePart1: 'Baños, paseos\n',
                titleCoral: 'y mimos',
                subtitle:
                    'Reserva servicios y sigue su paseo en vivo desde tu celular.',
                illustration: _Slide3Art(active: _currentIndex == 2),
              ),
            ],
          ),

          // Botón Saltar arriba a la derecha
          Positioned(
            top: HuLayout.top(context, 56),
            right: 22,
            child: HuPressable(
              onTap: _finish,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(19),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Saltar',
                  style: t.style(14, FontWeight.w600, t.ink),
                ),
              ),
            ),
          ),

          // Controles inferiores: puntos + botón coral que se expande en la última diapositiva
          Positioned(
            left: 28,
            right: 28,
            bottom: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentIndex ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentIndex
                              ? t.teal
                              : const Color(0xFFCFE0DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
                HuPressable(
                  onTap: _next,
                  semanticLabel: isLast ? 'Empezar' : 'Siguiente',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 360),
                    curve: const Cubic(0.2, 0.8, 0.2, 1.0),
                    height: 62,
                    width: isLast ? 160 : 62,
                    decoration: BoxDecoration(
                      color: t.coral,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xE6D9583F),
                          offset: Offset(0, 16),
                          blurRadius: 26,
                          spreadRadius: -16,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLast) ...[
                          Text(
                            'Empezar',
                            style: t.style(16, FontWeight.w600, Colors.white),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const HuIcon(
                          'i-chev',
                          size: 26,
                          color: Colors.white,
                          strokeWidth: 2.4,
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
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.gradient,
    required this.titlePart1,
    required this.titleCoral,
    required this.subtitle,
    required this.illustration,
  });

  final Gradient gradient;
  final String titlePart1;
  final String titleCoral;
  final String subtitle;
  final Widget illustration;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final illH = math.min(590.0, h * 0.615);
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: illH,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(48),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 440,
                    height: 590,
                    child: illustration,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 28,
              top: illH + 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: titlePart1,
                      style: t.style(32, FontWeight.w600, t.ink, 1.08, -0.4),
                      children: [
                        TextSpan(
                          text: titleCoral,
                          style:
                              t.style(32, FontWeight.w600, t.coral, 1.08, -0.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Text(
                      subtitle,
                      style: t.style(15.5, FontWeight.w600, t.ink2, 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animación flotante escalonada (`flin` + `bob` en el HTML).
class _FloatIn extends StatefulWidget {
  const _FloatIn({
    required this.active,
    required this.delayMs,
    required this.child,
  });

  final bool active;
  final int delayMs;
  final Widget child;

  @override
  State<_FloatIn> createState() => _FloatInState();
}

class _FloatInState extends State<_FloatIn> with TickerProviderStateMixin {
  late final AnimationController _inCtrl;
  late final AnimationController _bobCtrl;

  @override
  void initState() {
    super.initState();
    _inCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (widget.active) _start();
  }

  void _start() {
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      _inCtrl.forward(from: 0);
      _bobCtrl.repeat(reverse: true);
    });
  }

  @override
  void didUpdateWidget(covariant _FloatIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _inCtrl.value = 0;
      _start();
    }
  }

  @override
  void dispose() {
    _inCtrl.dispose();
    _bobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disable) return widget.child;
    return AnimatedBuilder(
      animation: Listenable.merge([_inCtrl, _bobCtrl]),
      builder: (context, child) {
        final c = const Cubic(0.2, 0.8, 0.2, 1.0).transform(_inCtrl.value);
        final bob = Curves.easeInOut.transform(_bobCtrl.value) * -6.0;
        return Opacity(
          opacity: c.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 22 * (1.0 - c) + bob * c),
            child: Transform.scale(
              scale: 0.92 + 0.08 * c,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.child, this.width, this.height, this.padding});
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x8C12324A),
            offset: Offset(0, 26),
            blurRadius: 44,
            spreadRadius: -26,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Slide1Art extends StatelessWidget {
  const _Slide1Art({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Stack(
      children: [
        Positioned(
          left: 70,
          top: 150,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 96,
          top: 150,
          width: 250,
          height: 250,
          child: _FloatIn(
            active: active,
            delayMs: 50,
            child: const HuArt('a-dog', width: 250, height: 250),
          ),
        ),
        Positioned(
          left: 250,
          top: 330,
          child: _FloatIn(
            active: active,
            delayMs: 200,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: t.coralSoft,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 8),
              ),
              clipBehavior: Clip.antiAlias,
              child: const HuArt('a-cat', width: 150, height: 150),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 120,
          child: _FloatIn(
            active: active,
            delayMs: 380,
            child: _MiniCard(
              width: 200,
              child: Row(
                children: [
                  const IconBox(
                    icon: 'i-syringe',
                    accent: HuAccent.lav,
                    size: 40,
                    radius: 13,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Vacunas al día',
                          style: t.style(14, FontWeight.w700, t.ink),
                        ),
                        Text(
                          '2 de 3 aplicadas',
                          style: t.style(12, FontWeight.w700, t.ok),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 36,
          top: 430,
          child: _FloatIn(
            active: active,
            delayMs: 520,
            child: _MiniCard(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Peso de Milo',
                    style: t.style(12, FontWeight.w700, t.ink2),
                  ),
                  Text(
                    '24.6 kg',
                    style: t.style(24, FontWeight.w600, t.ink, 1.15),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 140,
                    height: 34,
                    child: CustomPaint(painter: _MiniSparklinePainter(t.teal)),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 268,
          top: 108,
          child: _FloatIn(
            active: active,
            delayMs: 650,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(17),
                boxShadow: HuTokens.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuIcon(
                    'i-heart',
                    size: 14,
                    color: t.tealDeep,
                    strokeWidth: 2.4,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Saludable',
                    style: t.style(13, FontWeight.w500, t.tealDeep),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  _MiniSparklinePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(2, 30)
      ..lineTo(22, 26)
      ..lineTo(42, 24)
      ..lineTo(62, 20)
      ..lineTo(82, 16)
      ..lineTo(102, 12)
      ..lineTo(122, 8)
      ..lineTo(138, 6);
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) => false;
}

class _Slide2Art extends StatelessWidget {
  const _Slide2Art({required this.active, required this.monthName});
  final bool active;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Stack(
      children: [
        Positioned(
          left: 60,
          top: 140,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 70,
          top: 120,
          child: _FloatIn(
            active: active,
            delayMs: 50,
            child: _MiniCard(
              width: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(monthName, style: t.style(17, FontWeight.w600, t.ink)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: [
                      for (int k = 0; k < 21; k++)
                        Container(
                          decoration: BoxDecoration(
                            color: k == 11 ? t.teal : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${k + 6}',
                            style: t.style(
                              12.5,
                              FontWeight.w700,
                              k == 11 ? Colors.white : t.ink2,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final (idx, hStr)
                          in ['09:00', '10:30', '12:00'].indexed)
                        Expanded(
                          child: Container(
                            height: 34,
                            margin: EdgeInsets.only(right: idx < 2 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: idx == 1 ? t.teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                              border: idx == 1
                                  ? null
                                  : Border.all(color: t.line, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hStr,
                              style: t.style(
                                13,
                                FontWeight.w700,
                                idx == 1 ? Colors.white : t.ink,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 150,
          top: 420,
          child: _FloatIn(
            active: active,
            delayMs: 280,
            child: _MiniCard(
              width: 250,
              child: Row(
                children: [
                  HuPersonAvatar(
                    'sofia',
                    size: 48,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Dra. Sofía Méndez',
                          style: t.style(14.5, FontWeight.w700, t.ink),
                        ),
                        Text(
                          '★ 4.9 · Medicina general',
                          style: t.style(12, FontWeight.w600, t.ink2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 380,
          child: _FloatIn(
            active: active,
            delayMs: 460,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: t.tealSoft,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 7),
              ),
              clipBehavior: Clip.antiAlias,
              child: const HuArt('a-dog', width: 120, height: 120),
            ),
          ),
        ),
        Positioned(
          left: 236,
          top: 508,
          child: _FloatIn(
            active: active,
            delayMs: 620,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: HuTokens.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuIcon(
                    'i-bell',
                    size: 14,
                    color: t.tealDeep,
                    strokeWidth: 2.4,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Te avisamos',
                    style: t.style(13, FontWeight.w500, t.tealDeep),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Slide3Art extends StatelessWidget {
  const _Slide3Art({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Stack(
      children: [
        Positioned(
          left: 70,
          top: 160,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 60,
          top: 110,
          child: _FloatIn(
            active: active,
            delayMs: 50,
            child: _MiniCard(
              width: 320,
              height: 250,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _Slide3MiniMapPainter()),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                            style: t.style(12, FontWeight.w600, t.bad),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 230,
          top: 330,
          child: _FloatIn(
            active: active,
            delayMs: 280,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 7,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: const HuArt('a-groom', width: 150, height: 150),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 380,
          child: _FloatIn(
            active: active,
            delayMs: 460,
            child: _MiniCard(
              width: 210,
              child: Row(
                children: [
                  HuPersonAvatar(
                    'diego',
                    size: 44,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Diego pasea a Milo',
                          style: t.style(14, FontWeight.w700, t.ink),
                        ),
                        Text(
                          '18 min · 1.3 km',
                          style: t.style(12, FontWeight.w600, t.ink2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: 490,
          child: _FloatIn(
            active: active,
            delayMs: 620,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                boxShadow: HuTokens.cardShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HuIcon(
                    'i-scissors',
                    size: 14,
                    color: t.coralDeep,
                    strokeWidth: 2.4,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Baño listo a las 11:00',
                    style: t.style(13, FontWeight.w500, t.coralDeep),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Slide3MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAF4EF),
    );
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 14;
    canvas.drawLine(const Offset(0, 70), const Offset(320, 70), road);
    canvas.drawLine(const Offset(0, 170), const Offset(320, 170), road);
    canvas.drawLine(const Offset(90, 0), const Offset(90, 250), road);
    canvas.drawLine(const Offset(230, 0), const Offset(230, 250), road);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(110, 88, 100, 64),
        const Radius.circular(12),
      ),
      Paint()..color = const Color(0xFFCDEBD9),
    );

    final route = Path()
      ..moveTo(40, 210)
      ..cubicTo(80, 200, 90, 150, 140, 140)
      ..cubicTo(190, 130, 220, 90, 270, 40);
    canvas.drawPath(
      route,
      Paint()
        ..color = const Color(0xFF1F9E8F)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      const Offset(270, 40),
      10,
      Paint()..color = const Color(0xFFF2775E),
    );
    canvas.drawCircle(
      const Offset(270, 40),
      10,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _Slide3MiniMapPainter oldDelegate) => false;
}
