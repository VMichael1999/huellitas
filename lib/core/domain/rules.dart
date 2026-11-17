import 'dart:math' as math;

import '../format/hu_format.dart';
import '../theme/hu_tokens.dart';
import '../utils/clock.dart';
import '../utils/stable_hash.dart';
import 'models.dart';

/// Reglas de negocio de salud de la mascota (sección 4.2).
class PetHealthRules {
  static VaccineState vaccineState(DateTime today, Vaccine v) {
    final n = HuFormat.daysFrom(today, v.nextDue);
    if (n < 0) return VaccineState.late;
    if (n <= 14) return VaccineState.next;
    return VaccineState.ok;
  }

  static int healthScore(DateTime today, Pet p) {
    final lateCount =
        p.vaccines.where((v) => vaccineState(today, v) == VaccineState.late).length;
    final nextCount =
        p.vaccines.where((v) => vaccineState(today, v) == VaccineState.next).length;
    final raw = 96 -
        lateCount * 8 -
        nextCount * 2 +
        (p.mood == 'Decaído' ? -12 : 0) +
        (p.appetite == 'Nada'
            ? -10
            : p.appetite == 'Poco'
                ? -4
                : 0);
    return raw.clamp(55, 99);
  }

  static (String label, HuAccent accent) healthTag(int score) {
    if (score >= 85) return ('Saludable', HuAccent.ok);
    if (score >= 70) return ('Revisar', HuAccent.sun);
    return ('Atención', HuAccent.bad);
  }

  static String sizeOf(double weightKg) {
    if (weightKg < 10) return 'S';
    if (weightKg <= 25) return 'M';
    return 'L';
  }

  static const Map<String, (String title, String weightRange)> sizeLabels = {
    'S': ('Pequeño', 'hasta 10 kg'),
    'M': ('Mediano', '10 a 25 kg'),
    'L': ('Grande', 'más de 25 kg'),
  };
}

class TimeSlot {
  const TimeSlot({required this.minutes, required this.taken});
  final int minutes;
  final bool taken;
}

/// Patrón Strategy para cálculo de disponibilidad (`SlotStrategy`, `RangeStrategy`, `WalkStrategy`).
abstract class AvailabilityStrategy {
  const AvailabilityStrategy();

  List<TimeSlot>? slotsFor({
    required Clock clock,
    required String key,
    required Clinic clinic,
    required String dateIso,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? ignoreAppointmentId,
  });
}

class SlotStrategy extends AvailabilityStrategy {
  const SlotStrategy();

  @override
  List<TimeSlot>? slotsFor({
    required Clock clock,
    required String key,
    required Clinic clinic,
    required String dateIso,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? ignoreAppointmentId,
  }) {
    final dt = HuFormat.fromIso(dateIso);
    final w = HuFormat.jsDay(dt);
    if (!clinic.weekdays.contains(w)) return null;

    final start = clinic.is24h ? 480 : math.max(clinic.openStartMin, 540);
    final end = clinic.is24h ? 1260 : math.min(clinic.openEndMin, 1140);
    final todayIso = HuFormat.iso(clock.today);
    final nowMin = clock.nowMinutes;

    final out = <TimeSlot>[];
    for (int t = start; t + durationMinutes <= end; t += 30) {
      if (dateIso == todayIso && t < nowMin + 60) continue;
      final hashTaken = stableHash('$dateIso$key$t') % 100 < 36;
      final apptTaken = appointments.any((a) {
        if (a.status != AppointmentStatus.confirmed) return false;
        if (a.date != dateIso) return false;
        if (ignoreAppointmentId != null && a.id == ignoreAppointmentId) return false;
        final aKey = a.vetId ?? a.serviceId;
        if (aKey != key) return false;
        return (HuFormat.toMin(a.time) - t).abs() < 30;
      });
      out.add(TimeSlot(minutes: t, taken: hashTaken || apptTaken));
    }
    return out;
  }
}

class WalkStrategy extends SlotStrategy {
  const WalkStrategy();
}

class RangeStrategy {
  const RangeStrategy();

  int nights(String? startIso, String? endIso) {
    if (startIso == null || endIso == null) return 0;
    final s = HuFormat.fromIso(startIso);
    final e = HuFormat.fromIso(endIso);
    return math.max(0, e.difference(s).inDays);
  }
}

class AvailabilityService {
  const AvailabilityService({
    required this.clock,
    this.slotStrategy = const SlotStrategy(),
    this.walkStrategy = const WalkStrategy(),
    this.rangeStrategy = const RangeStrategy(),
  });

  final Clock clock;
  final SlotStrategy slotStrategy;
  final WalkStrategy walkStrategy;
  final RangeStrategy rangeStrategy;

  List<TimeSlot>? slotsFor({
    required String key,
    required Clinic clinic,
    required String dateIso,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? ignoreAppointmentId,
  }) =>
      slotStrategy.slotsFor(
        clock: clock,
        key: key,
        clinic: clinic,
        dateIso: dateIso,
        durationMinutes: durationMinutes,
        appointments: appointments,
        ignoreAppointmentId: ignoreAppointmentId,
      );

  int freeCount({
    required String key,
    required Clinic clinic,
    required String dateIso,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? ignoreAppointmentId,
  }) {
    final s = slotsFor(
      key: key,
      clinic: clinic,
      dateIso: dateIso,
      durationMinutes: durationMinutes,
      appointments: appointments,
      ignoreAppointmentId: ignoreAppointmentId,
    );
    if (s == null) return 0;
    return s.where((x) => !x.taken).length;
  }

  ({String d, int t})? nextFree({
    required String key,
    required Clinic clinic,
    required int durationMinutes,
    required List<Appointment> appointments,
  }) {
    final today = clock.today;
    for (int i = 0; i < 30; i++) {
      final d = HuFormat.rd(today, i);
      final s = slotsFor(
        key: key,
        clinic: clinic,
        dateIso: d,
        durationMinutes: durationMinutes,
        appointments: appointments,
      );
      if (s != null) {
        for (final slot in s) {
          if (!slot.taken) return (d: d, t: slot.minutes);
        }
      }
    }
    return null;
  }

  /// Primer día en los próximos 30 con >= 4 horas libres; si no hay, el primero con >= 1.
  String? defaultDate({
    required String key,
    required Clinic clinic,
    required int durationMinutes,
    required List<Appointment> appointments,
    String? ignoreAppointmentId,
  }) {
    final today = clock.today;
    for (int i = 0; i < 30; i++) {
      final d = HuFormat.rd(today, i);
      if (freeCount(
            key: key,
            clinic: clinic,
            dateIso: d,
            durationMinutes: durationMinutes,
            appointments: appointments,
            ignoreAppointmentId: ignoreAppointmentId,
          ) >=
          4) {
        return d;
      }
    }
    for (int i = 0; i < 30; i++) {
      final d = HuFormat.rd(today, i);
      if (freeCount(
            key: key,
            clinic: clinic,
            dateIso: d,
            durationMinutes: durationMinutes,
            appointments: appointments,
            ignoreAppointmentId: ignoreAppointmentId,
          ) >
          0) {
        return d;
      }
    }
    return null;
  }

  String? defaultTime(List<TimeSlot> freeSlots) {
    if (freeSlots.isEmpty) return null;
    final from10 = freeSlots.where((s) => s.minutes >= 600).toList();
    final pick = from10.isNotEmpty ? from10.first : freeSlots.first;
    return HuFormat.hm(pick.minutes);
  }
}

/// Patrón Specification para compatibilidad mascota–veterinario y filtros de clínicas.
class VetSpec {
  static bool canTreat(Vet vet, Pet pet, VisitType visitType) =>
      visitType.vetIds.contains(vet.id) && vet.species.contains(pet.species);

  static bool isClinicOpen(Clock clock, Clinic clinic) {
    final w = HuFormat.jsDay(clock.now());
    final m = clock.nowMinutes;
    return clinic.weekdays.contains(w) &&
        m >= clinic.openStartMin &&
        m < clinic.openEndMin;
  }
}

/// Reglas de citas (política de 12 horas), precios de servicios y envío de tienda.
class BookingPricingRules {
  static const double lateCancellationFee = 10.0;
  static const double pickupFee = 8.0;
  static const double freeShippingThreshold = 50.0;
  static const double standardShippingFee = 4.99;
  static const double expressShippingFee = 9.99;

  static bool isWithin12Hours(DateTime now, String dateIso, String timeHhMm) {
    final d = HuFormat.fromIso(dateIso);
    final min = HuFormat.toMin(timeHhMm);
    final apptDt = DateTime(d.year, d.month, d.day, min ~/ 60, min % 60);
    return apptDt.difference(now).inMilliseconds < 12 * 3600 * 1000;
  }

  static double cancellationFee(DateTime now, String dateIso, String timeHhMm) =>
      isWithin12Hours(now, dateIso, timeHhMm) ? lateCancellationFee : 0.0;

  static double serviceTotal({
    required ServiceCatalogItem service,
    required String size,
    required int durationMinutes,
    required int nights,
    required Set<String> extras,
    required Map<String, ServiceExtra> extrasCatalog,
    required bool pickup,
  }) {
    double base;
    if (service.sizePrices != null) {
      base = service.sizePrices![size] ?? 45.0;
    } else if (service.kind == ServiceKind.walk) {
      base = service.walkPrices?[durationMinutes] ?? 20.0;
    } else if (service.kind == ServiceKind.range) {
      base = (service.price ?? 35.0) * math.max(1, nights);
    } else {
      base = service.price ?? 15.0;
    }
    final extrasSum =
        extras.fold<double>(0.0, (acc, k) => acc + (extrasCatalog[k]?.price ?? 0.0));
    return base + extrasSum + (pickup ? pickupFee : 0.0);
  }

  static double shippingFee({required double subtotal, required bool express}) {
    if (express) return expressShippingFee;
    if (subtotal >= freeShippingThreshold) return 0.0;
    return standardShippingFee;
  }
}
