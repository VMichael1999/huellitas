import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/domain/rules.dart';
import '../../core/format/hu_format.dart';
import '../../core/utils/clock.dart';

enum BookingMode { create, reschedule }

class BookingState extends Equatable {
  const BookingState({
    this.mode = BookingMode.create,
    this.rescheduleAppointmentId,
    this.kind = AppointmentKind.vet,
    this.serviceId,
    required this.petId,
    this.typeId = 'check',
    this.vetId,
    this.selectedDate,
    this.selectedTime,
    required this.calendarMonth,
    this.showAllSlots = false,
    this.submitting = false,
  });

  final BookingMode mode;
  final String? rescheduleAppointmentId;
  final AppointmentKind kind;
  final String? serviceId;
  final String petId;
  final String typeId;
  final String? vetId;
  final String? selectedDate;
  final String? selectedTime;
  final DateTime calendarMonth;
  final bool showAllSlots;
  final bool submitting;

  bool get isReschedule => mode == BookingMode.reschedule;
  bool get isService => kind == AppointmentKind.svc;

  VisitType get visitType => DemoData.visitTypeById(typeId);
  Vet? get vet => vetId != null ? DemoData.vetById(vetId!) : null;
  String? get availabilityKey => isService ? serviceId : vetId;
  Clinic get clinic =>
      isService ? DemoData.clinicById('c1') : DemoData.clinicById(vet?.clinicId ?? 'c1');
  int get durationMinutes => isService
      ? (DemoData.serviceById(serviceId ?? 'groom').minutes ?? 30)
      : visitType.minutes;

  BookingState copyWith({
    BookingMode? mode,
    String? rescheduleAppointmentId,
    AppointmentKind? kind,
    String? serviceId,
    String? petId,
    String? typeId,
    String? vetId,
    bool clearVet = false,
    String? selectedDate,
    bool clearDate = false,
    String? selectedTime,
    bool clearTime = false,
    DateTime? calendarMonth,
    bool? showAllSlots,
    bool? submitting,
  }) =>
      BookingState(
        mode: mode ?? this.mode,
        rescheduleAppointmentId:
            rescheduleAppointmentId ?? this.rescheduleAppointmentId,
        kind: kind ?? this.kind,
        serviceId: serviceId ?? this.serviceId,
        petId: petId ?? this.petId,
        typeId: typeId ?? this.typeId,
        vetId: clearVet ? null : (vetId ?? this.vetId),
        selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
        selectedTime: clearTime ? null : (selectedTime ?? this.selectedTime),
        calendarMonth: calendarMonth ?? this.calendarMonth,
        showAllSlots: showAllSlots ?? this.showAllSlots,
        submitting: submitting ?? this.submitting,
      );

  @override
  List<Object?> get props => [
        mode,
        rescheduleAppointmentId,
        kind,
        serviceId,
        petId,
        typeId,
        vetId,
        selectedDate,
        selectedTime,
        calendarMonth,
        showAllSlots,
        submitting,
      ];
}

sealed class BookingEvent {
  const BookingEvent();
}

class BookingStarted extends BookingEvent {
  const BookingStarted({
    required this.pets,
    required this.appointments,
    this.petId,
    this.typeId,
    this.vetId,
    this.rescheduleAppointment,
  });

  final List<Pet> pets;
  final List<Appointment> appointments;
  final String? petId;
  final String? typeId;
  final String? vetId;
  final Appointment? rescheduleAppointment;
}

class BookingPetChanged extends BookingEvent {
  const BookingPetChanged({
    required this.petId,
    required this.pets,
    required this.appointments,
  });

  final String petId;
  final List<Pet> pets;
  final List<Appointment> appointments;
}

class BookingTypeChanged extends BookingEvent {
  const BookingTypeChanged({
    required this.typeId,
    required this.pets,
    required this.appointments,
  });

  final String typeId;
  final List<Pet> pets;
  final List<Appointment> appointments;
}

class BookingVetChanged extends BookingEvent {
  const BookingVetChanged({
    required this.vetId,
    required this.pets,
    required this.appointments,
  });

  final String vetId;
  final List<Pet> pets;
  final List<Appointment> appointments;
}

class BookingDateSelected extends BookingEvent {
  const BookingDateSelected({
    required this.dateIso,
    required this.appointments,
  });

  final String dateIso;
  final List<Appointment> appointments;
}

class BookingTimeSelected extends BookingEvent {
  const BookingTimeSelected(this.timeHhMm);
  final String timeHhMm;
}

class BookingMonthChanged extends BookingEvent {
  const BookingMonthChanged(this.deltaMonths);
  final int deltaMonths;
}

class BookingToggleShowAllSlots extends BookingEvent {
  const BookingToggleShowAllSlots();
}

class BookingSubmittingSet extends BookingEvent {
  const BookingSubmittingSet(this.submitting);
  final bool submitting;
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({required this.clock})
      : availability = AvailabilityService(clock: clock),
        super(BookingState(
          petId: 'milo',
          calendarMonth: DateTime(clock.today.year, clock.today.month, 1),
        )) {
    on<BookingStarted>((event, emit) {
      if (event.rescheduleAppointment != null) {
        final a = event.rescheduleAppointment!;
        final base = BookingState(
          mode: BookingMode.reschedule,
          rescheduleAppointmentId: a.id,
          kind: a.kind,
          serviceId: a.serviceId,
          petId: a.petId,
          typeId: a.typeId ?? 'check',
          vetId: a.vetId,
          selectedDate: a.date,
          selectedTime: null,
          calendarMonth: DateTime(
            HuFormat.fromIso(a.date).year,
            HuFormat.fromIso(a.date).month,
            1,
          ),
        );
        emit(_fixBook(base, event.pets, event.appointments));
        return;
      }

      if (event.pets.isEmpty) return;
      String pId = event.petId ?? event.pets.first.id;
      String tId = event.typeId ?? 'check';
      final vId = event.vetId;

      if (vId != null) {
        final v = DemoData.vetById(vId);
        final currentPet = event.pets.firstWhere(
          (p) => p.id == pId,
          orElse: () => event.pets.first,
        );
        if (!v.species.contains(currentPet.species)) {
          final match = event.pets.where((p) => v.species.contains(p.species)).toList();
          if (match.isNotEmpty) pId = match.first.id;
        }
        if (!DemoData.visitTypeById(tId).vetIds.contains(vId)) {
          final matchType =
              DemoData.visitTypes.where((t) => t.vetIds.contains(vId)).toList();
          if (matchType.isNotEmpty) tId = matchType.first.id;
        }
      }

      final initial = BookingState(
        mode: BookingMode.create,
        petId: pId,
        typeId: tId,
        vetId: vId,
        calendarMonth: DateTime(clock.today.year, clock.today.month, 1),
      );
      emit(_fixBook(initial, event.pets, event.appointments));
    });

    on<BookingPetChanged>((event, emit) {
      final updated = state.copyWith(petId: event.petId);
      emit(_fixBook(updated, event.pets, event.appointments));
    });

    on<BookingTypeChanged>((event, emit) {
      final updated = state.copyWith(typeId: event.typeId);
      emit(_fixBook(updated, event.pets, event.appointments));
    });

    on<BookingVetChanged>((event, emit) {
      if (state.vetId == event.vetId) return;
      final updated = state.copyWith(
        vetId: event.vetId,
        clearDate: true,
        clearTime: true,
      );
      emit(_fixBook(updated, event.pets, event.appointments, resetMonth: true));
    });

    on<BookingDateSelected>((event, emit) {
      final updated = state.copyWith(
        selectedDate: event.dateIso,
        clearTime: true,
      );
      emit(updated);
    });

    on<BookingTimeSelected>((event, emit) {
      emit(state.copyWith(selectedTime: event.timeHhMm));
    });

    on<BookingMonthChanged>((event, emit) {
      final nextMonth = DateTime(
        state.calendarMonth.year,
        state.calendarMonth.month + event.deltaMonths,
        1,
      );
      emit(state.copyWith(calendarMonth: nextMonth));
    });

    on<BookingToggleShowAllSlots>((event, emit) {
      emit(state.copyWith(showAllSlots: !state.showAllSlots));
    });

    on<BookingSubmittingSet>((event, emit) {
      emit(state.copyWith(submitting: event.submitting));
    });
  }

  final Clock clock;
  final AvailabilityService availability;

  List<Vet> compatibleVets(BookingState s, List<Pet> pets) {
    final pet = pets.firstWhere(
      (p) => p.id == s.petId,
      orElse: () => pets.first,
    );
    final t = s.visitType;
    return t.vetIds
        .map(DemoData.vetById)
        .where((v) => v.species.contains(pet.species))
        .toList();
  }

  List<({Vet vet, ({String d, int t})? nextFree})> vetsSorted(
    BookingState s,
    List<Pet> pets,
    List<Appointment> appointments,
  ) {
    final list = compatibleVets(s, pets)
        .map((v) => (
              vet: v,
              nextFree: availability.nextFree(
                key: v.id,
                clinic: DemoData.clinicById(v.clinicId),
                durationMinutes: s.durationMinutes,
                appointments: appointments,
              ),
            ))
        .toList();
    list.sort((a, b) {
      final ka = '${a.nextFree?.d ?? '9999'}${HuFormat.hm(a.nextFree?.t ?? 0)}';
      final kb = '${b.nextFree?.d ?? '9999'}${HuFormat.hm(b.nextFree?.t ?? 0)}';
      return ka.compareTo(kb);
    });
    return list;
  }

  List<TimeSlot> freeSlotsForCurrentDate(
    BookingState s,
    List<Appointment> appointments,
  ) {
    final key = s.availabilityKey;
    final date = s.selectedDate;
    if (key == null || date == null) return const [];
    final all = availability.slotsFor(
          key: key,
          clinic: s.clinic,
          dateIso: date,
          durationMinutes: s.durationMinutes,
          appointments: appointments,
          ignoreAppointmentId: s.rescheduleAppointmentId,
        ) ??
        const [];
    return all.where((x) => !x.taken).toList();
  }

  BookingState _fixBook(
    BookingState current,
    List<Pet> pets,
    List<Appointment> appointments, {
    bool resetMonth = false,
  }) {
    var s = current;
    if (pets.isEmpty) return s;

    if (!s.isService) {
      final validVets = compatibleVets(s, pets);
      if (s.vetId == null || !validVets.any((v) => v.id == s.vetId)) {
        final sorted = vetsSorted(s, pets, appointments);
        s = s.copyWith(
          vetId: sorted.isNotEmpty ? sorted.first.vet.id : null,
          clearVet: sorted.isEmpty,
          clearDate: true,
          clearTime: true,
        );
        resetMonth = true;
      }
    }

    final key = s.availabilityKey;
    if (key == null) return s;

    final c = s.clinic;
    final min = s.durationMinutes;

    if (s.selectedDate != null &&
        availability.freeCount(
              key: key,
              clinic: c,
              dateIso: s.selectedDate!,
              durationMinutes: min,
              appointments: appointments,
              ignoreAppointmentId: s.rescheduleAppointmentId,
            ) ==
            0) {
      s = s.copyWith(clearDate: true, clearTime: true);
    }

    if (s.selectedDate == null) {
      final defDate = availability.defaultDate(
        key: key,
        clinic: c,
        durationMinutes: min,
        appointments: appointments,
        ignoreAppointmentId: s.rescheduleAppointmentId,
      );
      s = s.copyWith(selectedDate: defDate);
      resetMonth = true;
    }

    final freeSlots = freeSlotsForCurrentDate(s, appointments);
    if (s.selectedTime != null &&
        !freeSlots.any((x) => HuFormat.hm(x.minutes) == s.selectedTime)) {
      s = s.copyWith(clearTime: true);
    }

    if (s.selectedTime == null && !s.isReschedule && freeSlots.isNotEmpty) {
      s = s.copyWith(selectedTime: availability.defaultTime(freeSlots));
    }

    if (resetMonth && s.selectedDate != null) {
      final d = HuFormat.fromIso(s.selectedDate!);
      s = s.copyWith(calendarMonth: DateTime(d.year, d.month, 1));
    }
    return s;
  }
}
