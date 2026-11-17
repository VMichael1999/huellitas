import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/hu_tokens.dart';

/// Sección 6: Splash «Huellas que llegan».
/// Usa un lienzo proporcional de 440×956, precarga el logo antes de iniciar la
/// línea de tiempo y dibuja las huellas de forma síncrona con `CustomPainter`
/// para que nunca haya parpadeos ni cortes al arrancar en iOS.
class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
    this.fixedSeconds,
    this.autoNavigate = true,
  });

  /// Permite fijar el segundo exacto en pruebas golden (0.9, 1.9, 3.2, 4.0 s).
  final double? fixedSeconds;
  final bool autoNavigate;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// 4.55 s de coreografía + 1.45 s de pausa final para apreciar el cierre antes de ir a Bienvenida.
  static const double _timelineSeconds = 6.0;
  late final AnimationController _ctrl;
  Timer? _startTimer;
  bool _started = false;
  bool _navigated = false;

  // Posiciones (x, y, rotación en grados) en el lienzo 440×956 del HTML:
  // [[54, 846, -24], [118, 790, -30], [112, 712, -26], [176, 656, -32], [168, 578, -28], [214, 526, -30]]
  // con rotate: r + (k % 2 ? 8 : -8)deg => -32, -22, -34, -24, -36, -22.
  static const List<(double x, double y, double deg)> _footprints = [
    (54, 846, -32),
    (118, 790, -22),
    (112, 712, -34),
    (176, 656, -24),
    (168, 578, -36),
    (214, 526, -22),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    if (widget.fixedSeconds != null) {
      _ctrl.value = (widget.fixedSeconds! / _timelineSeconds).clamp(0.0, 1.0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || widget.fixedSeconds != null) return;
    _started = true;

    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disable) {
      _ctrl.value = (4.7 / _timelineSeconds).clamp(0.0, 1.0);
      if (widget.autoNavigate) {
        _startTimer = Timer(const Duration(milliseconds: 800), _goNext);
      }
      return;
    }

    // Precarga el logo 3D y espera a que iOS termine la transición del LaunchScreen
    // antes de arrancar en 0.0 s para que no se pierda ningún tramo de la animación.
    precacheImage(
      const AssetImage('assets/logo/huellitas-logo-cola.png'),
      context,
    ).whenComplete(() {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _startTimer = Timer(const Duration(milliseconds: 180), () {
          if (!mounted) return;
          _ctrl.forward(from: 0.0).whenComplete(_goNext);
        });
      });
    });
  }

  void _goNext() {
    if (_navigated || !mounted || !widget.autoNavigate) return;
    _navigated = true;
    context.go('/onboarding');
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  static (double opacity, double scale) _stepAnim(
    double elapsedSec,
    double startSec,
  ) {
    final t = (elapsedSec - startSec) / 1.6;
    if (t <= 0 || t >= 1) return (0.0, 0.4);
    double opacity;
    if (t < 0.12) {
      opacity = t / 0.12;
    } else if (t < 0.70) {
      opacity = 1.0 - ((t - 0.12) / 0.58) * 0.1;
    } else {
      opacity = 0.9 * (1.0 - (t - 0.70) / 0.30);
    }
    double scale;
    if (t < 0.12) {
      scale = 0.4 + (1.08 - 0.4) * (t / 0.12);
    } else if (t < 0.22) {
      scale = 1.08 + (1.0 - 1.08) * ((t - 0.12) / 0.10);
    } else {
      scale = 1.0;
    }
    return (opacity.clamp(0.0, 1.0), scale);
  }

  static (double opacity, double dy, double scale, double deg) _logoLand(
    double sec,
  ) {
    final raw = (sec - 1.35) / 0.70;
    if (raw <= 0) return (0.0, -120.0, 0.5, -20.0);
    if (raw >= 1) return (1.0, 0.0, 1.0, 0.0);
    final t = Curves.easeOut.transform(raw);
    final opacity = (raw / 0.45).clamp(0.0, 1.0);
    double dy;
    double scale;
    double deg;
    if (t < 0.65) {
      final p = t / 0.65;
      dy = -120.0 + (8.0 - (-120.0)) * p;
      scale = 0.5 + (1.06 - 0.5) * p;
      deg = -20.0 + (4.0 - (-20.0)) * p;
    } else {
      final p = (t - 0.65) / 0.35;
      dy = 8.0 * (1.0 - p);
      scale = 1.06 + (1.0 - 1.06) * p;
      deg = 4.0 * (1.0 - p);
    }
    return (opacity, dy, scale, deg);
  }

  static double _heartScale(double sec) {
    final t = ((sec - 3.75) / 0.80).clamp(0.0, 1.0);
    if (t <= 0) return 0.0;
    if (t < 0.50) {
      return 1.35 * (t / 0.50);
    } else if (t < 0.70) {
      return 1.35 + (0.90 - 1.35) * ((t - 0.50) / 0.20);
    } else {
      return 0.90 + (1.0 - 0.90) * ((t - 0.70) / 0.30);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final sec = _ctrl.value * _timelineSeconds;
        final lightStatus = sec >= 2.4;

        // Onda circular teal (2.05 s, dura 1.0 s, escala 0 -> 22)
        final waveT = ((sec - 2.05) / 1.0).clamp(0.0, 1.0);
        final waveScale =
            const Cubic(0.6, 0.0, 0.2, 1.0).transform(waveT) * 22.0;

        // Logo (1.35 s, dura 0.7 s)
        final (logoOp, logoDy, logoScale, logoDeg) = _logoLand(sec);

        // Nombre «Huellitas» (2.6 s, dura 0.6 s)
        final nameT = ((sec - 2.6) / 0.6).clamp(0.0, 1.0);
        final nameC = const Cubic(0.2, 0.8, 0.2, 1.0).transform(nameT);

        // Latido (2.9 - 3.9 s)
        final beatT = ((sec - 2.9) / 1.0).clamp(0.0, 1.0);
        final beatProgress = Curves.ease.transform(beatT);

        // Lema (3.4 s, dura 0.6 s)
        final tagT = ((sec - 3.4) / 0.6).clamp(0.0, 1.0);
        final tagC = Curves.ease.transform(tagT);

        // Corazón (3.75 s, dura 0.8 s)
        final heartS = _heartScale(sec);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: lightStatus
              ? SystemUiOverlayStyle.light
                  .copyWith(statusBarColor: Colors.transparent)
              : SystemUiOverlayStyle.dark
                  .copyWith(statusBarColor: Colors.transparent),
          child: Scaffold(
            backgroundColor:
                waveScale >= 10 ? t.teal : const Color(0xFFE9F7F4),
            body: Stack(
              fit: StackFit.expand,
              children: [
                // Escena 440×956 escalada proporcionalmente a cualquier iPhone
                FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: 440,
                    height: 956,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Seis huellas síncronas en zigzag (0.0 – 2.6 s)
                        for (int k = 0; k < _footprints.length; k++)
                          Builder(
                            builder: (_) {
                              final fp = _footprints[k];
                              final (op, sc) = _stepAnim(sec, k * 0.2);
                              if (op <= 0) return const SizedBox.shrink();
                              return Positioned(
                                left: fp.$1,
                                top: fp.$2,
                                child: Opacity(
                                  opacity: op,
                                  child: Transform.rotate(
                                    angle: fp.$3 * math.pi / 180.0,
                                    child: Transform.scale(
                                      scale: sc,
                                      child: const SizedBox(
                                        width: 34,
                                        height: 34,
                                        child: CustomPaint(
                                          painter: _PawFootprintPainter(
                                            Color(0xFF88CFC2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // 2. Onda circular teal que nace bajo el logo y cubre las huellas
                        if (waveScale > 0)
                          Positioned(
                            left: 220 - 60,
                            top: 956 * 0.44 - 60,
                            child: Transform.scale(
                              scale: waveScale,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: t.teal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                        // 3. Logo final siempre montado en el árbol (evita parpadeo de decodificación)
                        Positioned(
                          left: 220 - 52,
                          top: 956 * 0.44 - 52,
                          child: Opacity(
                            opacity: logoOp,
                            child: Transform.translate(
                              offset: Offset(0, logoDy),
                              child: Transform.rotate(
                                angle: logoDeg * math.pi / 180.0,
                                child: Transform.scale(
                                  scale: logoScale,
                                  child: SizedBox(
                                    width: 132,
                                    height: 105,
                                    child: Image.asset(
                                      'assets/logo/huellitas-logo-cola.png',
                                      width: 132,
                                      height: 105,
                                      fit: BoxFit.contain,
                                      gaplessPlayback: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 3. «Huellitas» (2.6 s)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 956 * 0.44 + 76,
                          child: Opacity(
                            opacity: nameC,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1.0 - nameC)),
                              child: Text(
                                'Huellitas',
                                textAlign: TextAlign.center,
                                style: t.style(
                                  44,
                                  FontWeight.w700,
                                  Colors.white,
                                  1.15,
                                  -0.88,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 4. Línea de latido blanca (220×40) + corazón coral (2.9 – 4.55 s)
                        Positioned(
                          left: 220 - 110,
                          top: 956 * 0.44 + 142,
                          width: 220,
                          height: 40,
                          child: CustomPaint(
                            painter: _SplashBeatPainter(
                              lineProgress: beatProgress,
                              heartScale: heartS,
                              coralColor: t.coral,
                            ),
                          ),
                        ),

                        // 5. Lema «Cuidamos a quien te cuida» (3.4 s)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 90,
                          child: Opacity(
                            opacity: tagC,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1.0 - tagC)),
                              child: Text(
                                'Cuidamos a quien te cuida',
                                textAlign: TextAlign.center,
                                style: t.style(
                                  15,
                                  FontWeight.w500,
                                  Colors.white.withValues(alpha: 0.90),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Dibuja la huella `#i-paw` (`viewBox 0 0 24 24`) de forma 100% síncrona en Canvas.
class _PawFootprintPainter extends CustomPainter {
  const _PawFootprintPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 24.0;
    final sy = size.height / 24.0;
    canvas.save();
    canvas.scale(sx, sy);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(7, 9.5), width: 3.8, height: 4.8),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(11, 6.3), width: 3.8, height: 4.8),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(15.6, 7.2), width: 3.8, height: 4.8),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(18.6, 11.5), width: 3.4, height: 4.4),
      paint,
    );

    final pad = Path()
      ..moveTo(8.3, 17.2)
      ..cubicTo(8.3, 14.4, 10.3, 12.2, 12.6, 12.2)
      ..cubicTo(14.9, 12.2, 17.2, 14.6, 17.2, 17.0)
      ..cubicTo(17.2, 18.8, 15.8, 20.0, 14.1, 19.6)
      ..cubicTo(13.3, 19.4, 12.9, 19.0, 12.3, 19.0)
      ..cubicTo(11.7, 19.0, 11.2, 19.5, 10.3, 19.6)
      ..cubicTo(9.1, 19.8, 8.3, 19.1, 8.3, 17.2)
      ..close();
    canvas.drawPath(pad, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PawFootprintPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SplashBeatPainter extends CustomPainter {
  _SplashBeatPainter({
    required this.lineProgress,
    required this.heartScale,
    required this.coralColor,
  });

  final double lineProgress;
  final double heartScale;
  final Color coralColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (lineProgress > 0) {
      // M2 20 H70 L80 6 L92 34 L104 12 L112 20 H194
      final p = Path()
        ..moveTo(2, 20)
        ..lineTo(70, 20)
        ..lineTo(80, 6)
        ..lineTo(92, 34)
        ..lineTo(104, 12)
        ..lineTo(112, 20)
        ..lineTo(194, 20);
      final metrics = p.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final m = metrics.first;
        final sub = m.extractPath(0, m.length * lineProgress.clamp(0.0, 1.0));
        canvas.drawPath(
          sub,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 3
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }

    if (heartScale > 0) {
      canvas.save();
      canvas.translate(206, 20);
      canvas.scale(heartScale);
      canvas.translate(-206, -20);

      // M206 28 c-9-6-12-10-12-14 a5 5 0 0 1 12-2 a5 5 0 0 1 12 2 c0 4-3 8-12 14z
      final heart = Path()
        ..moveTo(206, 28)
        ..cubicTo(197, 22, 194, 18, 194, 14)
        ..arcToPoint(
          const Offset(206, 12),
          radius: const Radius.circular(5),
          clockwise: true,
        )
        ..arcToPoint(
          const Offset(218, 14),
          radius: const Radius.circular(5),
          clockwise: true,
        )
        ..cubicTo(218, 18, 215, 22, 206, 28)
        ..close();

      canvas.drawPath(heart, Paint()..color = coralColor);
      canvas.drawPath(
        heart,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBeatPainter oldDelegate) =>
      oldDelegate.lineProgress != lineProgress ||
      oldDelegate.heartScale != heartScale;
}
