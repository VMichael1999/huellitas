import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../theme/hu_tokens.dart';
import 'hu_icon.dart';

class MapPinData {
  const MapPinData({
    required this.id,
    required this.xPercent,
    required this.yPercent,
    this.label,
    this.is24h = false,
    this.selected = false,
    this.onTap,
  });

  final String id;
  final double xPercent;
  final double yPercent;
  final String? label;
  final bool is24h;
  final bool selected;
  final VoidCallback? onTap;
}

/// Interfaz `MapView` (sección 2) para poder cambiar luego a `google_maps_flutter`.
abstract class MapView extends StatelessWidget {
  const MapView({super.key});
}

/// Mapa ilustrado con `CustomPainter`: soporta modo mini (detalle de cita y SOS),
/// modo clínicas (`Veterinarias cerca`) y modo paseo en vivo (`LiveWalk`) con ruta
/// y marcador animado sobre `PathMetric`.
class IllustratedMap extends MapView {
  const IllustratedMap({
    super.key,
    this.height = 170,
    this.borderRadius = 22,
    this.showUserDot = true,
    this.pins = const [],
    this.singlePinColor,
    this.walkProgress,
    this.petArtKey = 'a-dog',
    this.largeMode = false,
  });

  final double height;
  final double borderRadius;
  final bool showUserDot;
  final List<MapPinData> pins;
  final Color? singlePinColor;
  final double? walkProgress;
  final String petArtKey;
  final bool largeMode;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
            final h = constraints.maxHeight.isFinite ? constraints.maxHeight : height;
            Offset? walkPos;
            if (walkProgress != null) {
              walkPos = _computeWalkOffset(Size(w, h), walkProgress!.clamp(0.0, 1.0));
            }
            return Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _IllustratedMapPainter(
                      showUserDot: showUserDot && walkProgress == null && !largeMode,
                      singlePinColor: singlePinColor,
                      walkProgress: walkProgress,
                      largeMode: largeMode,
                    ),
                  ),
                ),
                if (largeMode && showUserDot && walkProgress == null)
                  Positioned(
                    left: w * 0.50 - 9,
                    top: h * 0.58 - 9,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: t.sky,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: t.sky.withValues(alpha: 0.2),
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                for (final pin in pins)
                  Positioned(
                    left: (w * pin.xPercent / 100) - 70,
                    top: (h * pin.yPercent / 100) - 48,
                    width: 140,
                    child: GestureDetector(
                      onTap: pin.onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pin.label != null)
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: pin.selected ? t.teal : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: HuTokens.cardShadow,
                                border: Border.all(color: t.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                pin.label!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.style(
                                  12.5,
                                  FontWeight.w600,
                                  pin.selected ? Colors.white : t.ink,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: pin.is24h ? t.bad : t.teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (walkPos != null)
                  Positioned(
                    left: walkPos.dx - 26,
                    top: walkPos.dy - 26,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: t.coral, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x331D2A44),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: HuArt(petArtKey, width: 44, height: 44),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Path _buildWalkPath(double sx, double sy) {
    // M70 520 C 70 470, 120 450, 160 440 S 200 380, 200 330 S 250 250, 300 240 S 380 200, 370 150 S 300 90, 250 100
    final p = Path();
    p.moveTo(70 * sx, 520 * sy);
    p.cubicTo(70 * sx, 470 * sy, 120 * sx, 450 * sy, 160 * sx, 440 * sy);
    p.cubicTo(200 * sx, 430 * sy, 200 * sx, 380 * sy, 200 * sx, 330 * sy);
    p.cubicTo(200 * sx, 280 * sy, 250 * sx, 250 * sy, 300 * sx, 240 * sy);
    p.cubicTo(350 * sx, 230 * sy, 380 * sx, 200 * sy, 370 * sx, 150 * sy);
    p.cubicTo(360 * sx, 100 * sy, 300 * sx, 90 * sy, 250 * sx, 100 * sy);
    return p;
  }

  static Offset _computeWalkOffset(Size size, double progress) {
    final sx = size.width / 440.0;
    final sy = size.height / 600.0;
    final path = _buildWalkPath(sx, sy);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return Offset(70 * sx, 520 * sy);
    final m = metrics.first;
    final tangent = m.getTangentForOffset(m.length * progress);
    return tangent?.position ?? Offset(70 * sx, 520 * sy);
  }
}

class _IllustratedMapPainter extends CustomPainter {
  _IllustratedMapPainter({
    required this.showUserDot,
    required this.singlePinColor,
    required this.walkProgress,
    required this.largeMode,
  });

  final bool showUserDot;
  final Color? singlePinColor;
  final double? walkProgress;
  final bool largeMode;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAF4EF),
    );

    if (walkProgress != null) {
      final sx = size.width / 440.0;
      final sy = size.height / 600.0;

      // Agua arriba a la derecha
      final water = Path()
        ..moveTo(260 * sx, 0)
        ..cubicTo(330 * sx, 60 * sy, 440 * sx, 60 * sy, 440 * sx, 120 * sy)
        ..lineTo(440 * sx, 0)
        ..close();
      canvas.drawPath(water, Paint()..color = const Color(0xFFD6ECF7));

      // Parque
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(230 * sx, 160 * sy, 190 * sx, 130 * sy),
          Radius.circular(30 * sx),
        ),
        Paint()..color = const Color(0xFFCDEBD9),
      );
      final treePaint = Paint()..color = const Color(0xFFB6E0C6);
      canvas.drawCircle(Offset(300 * sx, 220 * sy), 10 * sx, treePaint);
      canvas.drawCircle(Offset(350 * sx, 250 * sy), 14 * sx, treePaint);
      canvas.drawCircle(Offset(380 * sx, 200 * sy), 9 * sx, treePaint);

      // Calles principales
      final majorRoad = Paint()
        ..color = Colors.white
        ..strokeWidth = 16 * sx
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-10 * sx, 440 * sy), Offset(450 * sx, 420 * sy), majorRoad);
      canvas.drawLine(Offset(200 * sx, -10 * sy), Offset(180 * sx, 610 * sy), majorRoad);
      canvas.drawLine(Offset(-10 * sx, 300 * sy), Offset(450 * sx, 330 * sy), majorRoad);

      // Calles secundarias
      final minorRoad = Paint()
        ..color = Colors.white
        ..strokeWidth = 7 * sx
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(80 * sx, -10 * sy), Offset(60 * sx, 610 * sy), minorRoad);
      canvas.drawLine(Offset(330 * sx, -10 * sy), Offset(350 * sx, 610 * sy), minorRoad);
      canvas.drawLine(Offset(-10 * sx, 140 * sy), Offset(450 * sx, 120 * sy), minorRoad);
      canvas.drawLine(Offset(-10 * sx, 540 * sy), Offset(450 * sx, 520 * sy), minorRoad);

      // Casa de salida
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(40 * sx, 480 * sy, 50 * sx, 40 * sy),
          Radius.circular(8 * sx),
        ),
        Paint()..color = const Color(0xFFFCE3DB),
      );

      // Ruta prevista y recorrida
      final routePath = IllustratedMap._buildWalkPath(sx, sy);
      canvas.drawPath(
        routePath,
        Paint()
          ..color = const Color(0x401F9E8F)
          ..strokeWidth = 14 * sx
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      final metrics = routePath.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final m = metrics.first;
        final donePath = m.extractPath(0, m.length * walkProgress!.clamp(0.0, 1.0));
        canvas.drawPath(
          donePath,
          Paint()
            ..color = const Color(0xFF1F9E8F)
            ..strokeWidth = 6 * sx
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }

      // Punto de inicio
      canvas.drawCircle(
        Offset(70 * sx, 520 * sy),
        9 * sx,
        Paint()..color = const Color(0xFF12324A),
      );
      canvas.drawCircle(
        Offset(70 * sx, 520 * sy),
        9 * sx,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * sx,
      );
      return;
    }

    if (largeMode) {
      final sx = size.width / 400.0;
      final sy = size.height / 420.0;
      final water = Path()
        ..moveTo(0, 330 * sy)
        ..cubicTo(100 * sx, 300 * sy, 180 * sx, 360 * sy, 260 * sx, 320 * sy)
        ..cubicTo(340 * sx, 280 * sy, 380 * sx, 300 * sy, 400 * sx, 310 * sy)
        ..lineTo(400 * sx, 420 * sy)
        ..lineTo(0, 420 * sy)
        ..close();
      canvas.drawPath(water, Paint()..color = const Color(0xFFD6ECF7));

      final majorRoad = Paint()
        ..color = Colors.white
        ..strokeWidth = 14 * sx
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(-10 * sx, 120 * sy), Offset(410 * sx, 150 * sy), majorRoad);
      canvas.drawLine(Offset(140 * sx, -10 * sy), Offset(170 * sx, 430 * sy), majorRoad);
      canvas.drawLine(Offset(300 * sx, -10 * sy), Offset(270 * sx, 430 * sy), majorRoad);

      final minorRoad = Paint()
        ..color = Colors.white
        ..strokeWidth = 6 * sx
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(40 * sx, -10 * sy), Offset(60 * sx, 430 * sy), minorRoad);
      canvas.drawLine(Offset(220 * sx, -10 * sy), Offset(222 * sx, 430 * sy), minorRoad);
      canvas.drawLine(Offset(-10 * sx, 240 * sy), Offset(410 * sx, 226 * sy), minorRoad);

      final parkPaint = Paint()..color = const Color(0xFFCDEBD9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(180 * sx, 170 * sy, 70 * sx, 44 * sy),
          Radius.circular(10 * sx),
        ),
        parkPaint,
      );
      canvas.drawCircle(Offset(80 * sx, 60 * sy), 26 * sx, parkPaint);
      return;
    }

    // Modo compacto (400 x 170)
    final sx = size.width / 400.0;
    final sy = size.height / 170.0;
    final water = Path()
      ..moveTo(0, 130 * sy)
      ..cubicTo(90 * sx, 118 * sy, 150 * sx, 150 * sy, 240 * sx, 128 * sy)
      ..cubicTo(330 * sx, 106 * sy, 360 * sx, 110 * sy, 400 * sx, 118 * sy)
      ..lineTo(400 * sx, 170 * sy)
      ..lineTo(0, 170 * sy)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFD6ECF7));

    final majorRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 11 * sx
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10 * sx, 52 * sy), Offset(410 * sx, 70 * sy), majorRoad);
    canvas.drawLine(Offset(128 * sx, -10 * sy), Offset(150 * sx, 180 * sy), majorRoad);
    canvas.drawLine(Offset(290 * sx, -10 * sy), Offset(262 * sx, 180 * sy), majorRoad);

    final minorRoad = Paint()
      ..color = Colors.white
      ..strokeWidth = 5 * sx
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(40 * sx, -10 * sy), Offset(58 * sx, 180 * sy), minorRoad);
    canvas.drawLine(Offset(210 * sx, -10 * sy), Offset(214 * sx, 180 * sy), minorRoad);
    canvas.drawLine(Offset(-10 * sx, 102 * sy), Offset(410 * sx, 92 * sy), minorRoad);

    final parkPaint = Paint()..color = const Color(0xFFCDEBD9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(160 * sx, 78 * sy, 40 * sx, 22 * sy),
        Radius.circular(5 * sx),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(300 * sx, 20 * sy, 44 * sx, 26 * sy),
        Radius.circular(6 * sx),
      ),
      parkPaint,
    );
    canvas.drawCircle(Offset(76 * sx, 26 * sy), 16 * sx, parkPaint);

    if (showUserDot) {
      canvas.drawCircle(
        Offset(110 * sx, 118 * sy),
        7 * sx,
        Paint()..color = const Color(0xFF3D9BE9),
      );
      canvas.drawCircle(
        Offset(110 * sx, 118 * sy),
        7 * sx,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * sx,
      );
    }

    if (singlePinColor != null) {
      final px = 214 * sx;
      final py = 82 * sy;
      final pinPath = Path()
        ..moveTo(px, py)
        ..cubicTo(px - 12 * sx, py - 10.5 * sy, px - 12 * sx, py - 20 * sy, px - 12 * sx, py - 20 * sy)
        ..arcToPoint(
          Offset(px + 12 * sx, py - 20 * sy),
          radius: Radius.circular(12 * sx),
          clockwise: true,
        )
        ..cubicTo(px + 12 * sx, py - 10.5 * sy, px, py, px, py)
        ..close();
      canvas.drawPath(pinPath, Paint()..color = singlePinColor!);
      canvas.drawPath(
        pinPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * sx,
      );
      canvas.drawCircle(Offset(px, py - 20 * sy), 4.5 * sx, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _IllustratedMapPainter oldDelegate) =>
      oldDelegate.walkProgress != walkProgress ||
      oldDelegate.singlePinColor != singlePinColor ||
      oldDelegate.showUserDot != showUserDot ||
      oldDelegate.largeMode != largeMode;
}

/// Gráfico de peso de 8 meses con área degradada y etiqueta en el último punto (`WeightChart`).
class WeightChart extends StatelessWidget {
  const WeightChart({super.key, required this.weights});
  final List<double> weights;

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: t.border),
        boxShadow: HuTokens.cardShadow,
      ),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: CustomPaint(
          painter: _WeightChartPainter(weights: weights),
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({required this.weights});
  final List<double> weights;

  @override
  void paint(Canvas canvas, Size size) {
    if (weights.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final sy = h / 130.0;
    final gridPaint = Paint()
      ..color = const Color(0xFFE3EEEB)
      ..strokeWidth = 1;
    for (int k = 0; k < 3; k++) {
      final y = (20 + k * 45) * sy;
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    final minW = weights.reduce(math.min) - 0.5;
    final maxW = weights.reduce(math.max) + 0.5;
    final span = (maxW - minW) == 0 ? 1.0 : (maxW - minW);

    final pts = <Offset>[];
    for (int k = 0; k < weights.length; k++) {
      final x = weights.length == 1
          ? w / 2
          : 14 + k * (w - 28) / (weights.length - 1);
      final y = h - 16 * sy - ((weights[k] - minW) / span) * (h - 36 * sy);
      pts.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }

    if (pts.length > 1) {
      final areaPath = Path.from(linePath)
        ..lineTo(pts.last.dx, h)
        ..lineTo(pts.first.dx, h)
        ..close();
      canvas.drawPath(
        areaPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(0, h),
            [
              const Color(0xFF1F9E8F).withValues(alpha: 0.25),
              const Color(0xFF1F9E8F).withValues(alpha: 0.0),
            ],
          ),
      );
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF1F9E8F)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (int i = 0; i < pts.length; i++) {
      final isLast = i == pts.length - 1;
      final r = isLast ? 5.5 : 3.0;
      canvas.drawCircle(
        pts[i],
        r,
        Paint()..color = isLast ? const Color(0xFF1F9E8F) : Colors.white,
      );
      canvas.drawCircle(
        pts[i],
        r,
        Paint()
          ..color = const Color(0xFF1F9E8F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    final lastVal = weights.last;
    final label = '${lastVal == lastVal.roundToDouble() ? lastVal.toInt() : lastVal} kg';
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontFamily: HuTokens.font,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF12324A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        (pts.last.dx - tp.width - 4).clamp(0.0, w - tp.width),
        (pts.last.dy - tp.height - 8).clamp(0.0, h - tp.height),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) =>
      oldDelegate.weights != weights;
}

/// Círculo de confirmación `teal` con check y 6 huellas `coral` que salen (`PawBurst`).
class PawBurst extends StatefulWidget {
  const PawBurst({super.key});

  @override
  State<PawBurst> createState() => _PawBurstState();
}

class _PawBurstState extends State<PawBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _paws = [
    (-70.0, -60.0, -20.0),
    (70.0, -64.0, 25.0),
    (-84.0, 20.0, -40.0),
    (86.0, 24.0, 30.0),
    (-30.0, -90.0, 10.0),
    (34.0, 84.0, -15.0),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.hu;
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnim) {
      return SizedBox(
        width: 170,
        height: 170,
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: t.teal, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const HuIcon('i-check', size: 60, color: Colors.white, strokeWidth: 2.4),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final v = _ctrl.value;
        final popT = ((v - 0.07) / 0.38).clamp(0.0, 1.0);
        final popScale = Curves.elasticOut.transform(popT);
        final flyT = ((v - 0.31) / 0.69).clamp(0.0, 1.0);
        final flyCurve = Curves.easeOutCubic.transform(flyT);
        final pawOpacity = flyT < 0.3
            ? (flyT / 0.3)
            : (1.0 - (flyT - 0.3) / 0.7).clamp(0.0, 1.0);

        return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (final p in _paws)
                Transform.translate(
                  offset: Offset(p.$1 * flyCurve, p.$2 * flyCurve),
                  child: Transform.rotate(
                    angle: p.$3 * math.pi / 180 * flyCurve,
                    child: Transform.scale(
                      scale: 0.4 + 0.6 * flyCurve,
                      child: Opacity(
                        opacity: pawOpacity,
                        child: HuIcon(
                          'i-paw',
                          size: 22,
                          color: t.coral,
                          fill: t.coral,
                          strokeWidth: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              Transform.scale(
                scale: popScale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: t.teal, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const HuIcon(
                    'i-check',
                    size: 60,
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
