import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/hu_tokens.dart';
import 'illustrated_map.dart';

/// Centro de la zona de demostración (Miraflores, Lima). Los datos demo
/// expresan posiciones en porcentajes; aquí se convierten a coordenadas reales.
const LatLng kHuMapCenter = LatLng(-12.1211, -77.0297);
const double _kSpanDegrees = 0.016;

/// Convierte una posición en porcentaje (0–100) a coordenadas geográficas.
LatLng huLatLngFromPercent(double xPercent, double yPercent) => LatLng(
      kHuMapCenter.latitude - (yPercent - 50) / 100 * _kSpanDegrees,
      kHuMapCenter.longitude + (xPercent - 50) / 100 * _kSpanDegrees,
    );

/// Permite desactivar Google Maps (por ejemplo en pruebas de widgets, donde no
/// hay vista nativa) y volver al mapa ilustrado.
class HuMapConfig {
  const HuMapConfig._();

  static bool useGoogleMaps = true;
}

/// Implementación de [MapView] sobre `google_maps_flutter`. Mantiene la misma
/// API que [IllustratedMap]: pines, pin único, ruta de paseo y punto de usuario.
class GoogleMapView extends MapView {
  const GoogleMapView({
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

  bool get _isWalk => walkProgress != null;
  bool get _interactive => largeMode || _isWalk;

  static LatLng _fromWalkPoint(Offset o) =>
      huLatLngFromPercent(o.dx / 440 * 100, o.dy / 600 * 100);

  List<LatLng> _walkRoute() {
    final metrics =
        IllustratedMap.buildWalkPath(1, 1).computeMetrics().toList();
    if (metrics.isEmpty) return const [];
    final m = metrics.first;
    return [
      for (double d = 0; d < m.length; d += 8)
        _fromWalkPoint(m.getTangentForOffset(d)!.position),
      _fromWalkPoint(m.getTangentForOffset(m.length)!.position),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!HuMapConfig.useGoogleMaps) {
      return IllustratedMap(
        height: height,
        borderRadius: borderRadius,
        showUserDot: showUserDot,
        pins: pins,
        singlePinColor: singlePinColor,
        walkProgress: walkProgress,
        petArtKey: petArtKey,
        largeMode: largeMode,
      );
    }
    final t = context.hu;
    final markers = <Marker>{};
    final polylines = <Polyline>{};
    final circles = <Circle>{};

    if (_isWalk) {
      final route = _walkRoute();
      final progress = walkProgress!.clamp(0.0, 1.0);
      final cut = (route.length * progress).round().clamp(1, route.length);
      polylines
        ..add(Polyline(
          polylineId: const PolylineId('route'),
          points: route,
          color: t.teal.withValues(alpha: 0.35),
          width: 5,
          patterns: [PatternItem.dash(16), PatternItem.gap(10)],
        ))
        ..add(Polyline(
          polylineId: const PolylineId('route-done'),
          points: route.sublist(0, cut),
          color: t.teal,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ));
      markers
        ..add(Marker(
          markerId: const MarkerId('start'),
          position: route.first,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ))
        ..add(Marker(
          markerId: const MarkerId('pet'),
          position: route[cut - 1],
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange),
        ));
    } else if (pins.isNotEmpty) {
      for (final p in pins) {
        markers.add(Marker(
          markerId: MarkerId(p.id),
          position: huLatLngFromPercent(p.xPercent, p.yPercent),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            p.is24h ? BitmapDescriptor.hueRed : BitmapDescriptor.hueCyan,
          ),
          zIndexInt: p.selected ? 1 : 0,
          infoWindow:
              p.label == null ? InfoWindow.noText : InfoWindow(title: p.label),
          onTap: p.onTap,
        ));
      }
    } else {
      final color = singlePinColor ?? t.teal;
      markers.add(Marker(
        markerId: const MarkerId('single'),
        position: kHuMapCenter,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          HSVColor.fromColor(color).hue,
        ),
      ));
    }

    if (showUserDot) {
      final user = huLatLngFromPercent(_isWalk ? 40 : 38, _isWalk ? 62 : 64);
      circles
        ..add(Circle(
          circleId: const CircleId('user-halo'),
          center: user,
          radius: 60,
          fillColor: const Color(0x331E88E5),
          strokeWidth: 0,
        ))
        ..add(Circle(
          circleId: const CircleId('user'),
          center: user,
          radius: 16,
          fillColor: const Color(0xFF1E88E5),
          strokeColor: const Color(0xFFFFFFFF),
          strokeWidth: 3,
        ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: kHuMapCenter,
            zoom: _interactive ? 14.8 : 15.6,
          ),
          markers: markers,
          polylines: polylines,
          circles: circles,
          liteModeEnabled: !_interactive &&
              defaultTargetPlatform == TargetPlatform.android,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: _interactive,
          scrollGesturesEnabled: _interactive,
          zoomGesturesEnabled: _interactive,
          tiltGesturesEnabled: false,
          gestureRecognizers: _interactive
              ? {
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                }
              : const {},
        ),
      ),
    );
  }
}
