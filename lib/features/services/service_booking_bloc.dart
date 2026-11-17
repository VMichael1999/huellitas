import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/domain/rules.dart';
import '../../core/format/hu_format.dart';
import '../../core/utils/clock.dart';

class ServiceBookingState extends Equatable {
  const ServiceBookingState({
    this.serviceId = 'groom',
    this.petId = 'milo',
    this.size = 'M',
    this.extras = const {},
    this.pickup = false,
    this.selectedDate,
    this.selectedTime,
    this.endDate,
    this.walkDuration = 30,
    this.walkerId = 'diego',
    this.submitting = false,
  });

  final String serviceId;
  final String petId;
  final String size; // 'S' | 'M' | 'L'
  final Set<String> extras;
  final bool pickup;
  final String? selectedDate;
  final String? selectedTime;
  final String? endDate;
  final int walkDuration; // 30 | 60
  final String walkerId;
  final bool submitting;

  ServiceCatalogItem get service => DemoData.serviceById(serviceId);
  String get availabilityKey => serviceId == 'walk' ? walkerId : serviceId;
  Clinic get clinic =>
      DemoData.clinicById(serviceId == 'walk' ? 'c3' : 'c1');
  int get durationMinutes =>
      serviceId == 'walk' ? walkDuration : (service.minutes ?? 30);

  int get nights {
    if (selectedDate == null || endDate == null) return 0;
    return const RangeStrategy().nights(selectedDate, endDate);
  }

  bool get isValid => service.kind == ServiceKind.range
      ? (selectedDate != null && endDate != null && nights > 0)
      : (selectedDate != null && selectedTime != null);

  double get totalPrice => BookingPricingRules.serviceTotal(
        service: service,
        size: size,
        durationMinutes: walkDuration,
        nights: nights,
        extras: extras,
        extrasCatalog: DemoData.extras,
        pickup: pickup,
      );

  ServiceBookingState copyWith({
    String? serviceId,
    String? petId,
    String? size,
    Set<String>? extras,
    bool? pickup,
    String? selectedDate,
    bool clearDate = false,
    String? selectedTime,
    bool clearTime = false,
    String? endDate,
    bool clearEnd = false,
    int? walkDuration,
    String? walkerId,
    bool? submitting,
  }) =>
      ServiceBookingState(
        serviceId: serviceId ?? this.serviceId,
        petId: petId ?? this.petId,
        size: size ?? this.size,
        extras: extras ?? this.extras,
        pickup: pickup ?? this.pickup,
        selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
        selectedTime: clearTime ? null : (selectedTime ?? this.selectedTime),
        endDate: clearEnd ? null : (endDate ?? this.endDate),
        walkDuration: walkDuration ?? this.walkDuration,
        walkerId: walkerId ?? this.walkerId,
        submitting: submitting ?? this.submitting,
      );

  @override
  List<Object?> get props => [
        serviceId,
        petId,
        size,
        extras,
        pickup,
        selectedDate,
        selectedTime,
        endDate,
        walkDuration,
        walkerId,
        submitting,
      ];
}

sealed class ServiceBookingEvent {
  const ServiceBookingEvent();
}

class ServiceBookingOpened extends ServiceBookingEvent {
  const ServiceBookingOpened({
    required this.serviceId,
    required this.pet,
    required this.appointments,
  });

  final String serviceId;
  final Pet pet;
  final List<Appointment> appointments;
}

class ServiceBookingPetChanged extends ServiceBookingEvent {
  const ServiceBookingPetChanged(this.pet);
  final Pet pet;
}

class ServiceBookingSizeChanged extends ServiceBookingEvent {
  const ServiceBookingSizeChanged(this.size);
  final String size;
}

class ServiceBookingExtraToggled extends ServiceBookingEvent {
  const ServiceBookingExtraToggled(this.extraId);
  final String extraId;
}

class ServiceBookingDurationChanged extends ServiceBookingEvent {
  const ServiceBookingDurationChanged(this.minutes);
  final int minutes;
}

class ServiceBookingWalkerChanged extends ServiceBookingEvent {
  const ServiceBookingWalkerChanged(this.walkerId);
  final String walkerId;
}

class ServiceBookingDaySelected extends ServiceBookingEvent {
  const ServiceBookingDaySelected(this.dateIso);
  final String dateIso;
}

class ServiceBookingRangeDayTapped extends ServiceBookingEvent {
  const ServiceBookingRangeDayTapped(this.dateIso);
  final String dateIso;
}

class ServiceBookingTimeSelected extends ServiceBookingEvent {
  const ServiceBookingTimeSelected(this.timeHhMm);
  final String timeHhMm;
}

class ServiceBookingPickupToggled extends ServiceBookingEvent {
  const ServiceBookingPickupToggled();
}

class ServiceBookingSubmittingSet extends ServiceBookingEvent {
  const ServiceBookingSubmittingSet(this.submitting);
  final bool submitting;
}

class ServiceBookingBloc
    extends Bloc<ServiceBookingEvent, ServiceBookingState> {
  ServiceBookingBloc({required this.clock})
      : availability = AvailabilityService(clock: clock),
        super(const ServiceBookingState()) {
    on<ServiceBookingOpened>((event, emit) {
      final base = ServiceBookingState(
        serviceId: event.serviceId,
        petId: event.pet.id,
        size: PetHealthRules.sizeOf(event.pet.weightKg),
      );
      emit(_ensureValidDate(base, event.appointments));
    });
    on<ServiceBookingPetChanged>((event, emit) {
      emit(state.copyWith(
        petId: event.pet.id,
        size: PetHealthRules.sizeOf(event.pet.weightKg),
      ));
    });
    on<ServiceBookingSizeChanged>((event, emit) {
      emit(state.copyWith(size: event.size));
    });
    on<ServiceBookingExtraToggled>((event, emit) {
      final next = Set<String>.from(state.extras);
      if (!next.remove(event.extraId)) {
        next.add(event.extraId);
      }
      emit(state.copyWith(extras: next));
    });
    on<ServiceBookingDurationChanged>((event, emit) {
      emit(state.copyWith(walkDuration: event.minutes, clearTime: true));
    });
    on<ServiceBookingWalkerChanged>((event, emit) {
      emit(state.copyWith(walkerId: event.walkerId, clearTime: true));
    });
    on<ServiceBookingDaySelected>((event, emit) {
      emit(state.copyWith(selectedDate: event.dateIso, clearTime: true));
    });
    on<ServiceBookingRangeDayTapped>((event, emit) {
      final d = event.dateIso;
      if (state.selectedDate == null ||
          state.endDate != null ||
          d.compareTo(state.selectedDate!) <= 0) {
        emit(state.copyWith(selectedDate: d, clearEnd: true));
      } else {
        emit(state.copyWith(endDate: d));
      }
    });
    on<ServiceBookingTimeSelected>((event, emit) {
      emit(state.copyWith(selectedTime: event.timeHhMm));
    });
    on<ServiceBookingPickupToggled>((event, emit) {
      emit(state.copyWith(pickup: !state.pickup));
    });
    on<ServiceBookingSubmittingSet>((event, emit) {
      emit(state.copyWith(submitting: event.submitting));
    });
  }

  final Clock clock;
  final AvailabilityService availability;

  List<String> get next14Days =>
      List.generate(14, (i) => HuFormat.rd(clock.today, i));

  ServiceBookingState _ensureValidDate(
    ServiceBookingState s,
    List<Appointment> appointments,
  ) {
    if (s.service.kind == ServiceKind.range) return s;
    final days = next14Days;
    String? pick = days.cast<String?>().firstWhere(
          (d) =>
              availability.freeCount(
                key: s.availabilityKey,
                clinic: s.clinic,
                dateIso: d!,
                durationMinutes: s.durationMinutes,
                appointments: appointments,
              ) >=
              4,
          orElse: () => null,
        );
    pick ??= days.cast<String?>().firstWhere(
          (d) =>
              availability.freeCount(
                key: s.availabilityKey,
                clinic: s.clinic,
                dateIso: d!,
                durationMinutes: s.durationMinutes,
                appointments: appointments,
              ) >
              0,
          orElse: () => days.first,
        );
    return s.copyWith(selectedDate: pick);
  }
}
