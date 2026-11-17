import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/utils/clock.dart';

class AppointmentsState extends Equatable {
  const AppointmentsState({
    required this.appointments,
    this.sequence = 4100,
    this.segment = 'up', // 'up' | 'past'
    this.selectedAppointmentId,
    this.loadingSkeleton = false,
    this.doneData,
  });

  final List<Appointment> appointments;
  final int sequence;
  final String segment;
  final String? selectedAppointmentId;
  final bool loadingSkeleton;
  final DoneScreenData? doneData;

  List<Appointment> upcoming(DateTime today) {
    final list = appointments
        .where((a) =>
            a.status == AppointmentStatus.confirmed &&
            HuFormat.daysFrom(today, a.date) >= 0)
        .toList();
    list.sort((a, b) => '${a.date}${a.time}'.compareTo('${b.date}${b.time}'));
    return list;
  }

  List<Appointment> past(DateTime today) {
    final up = upcoming(today).toSet();
    final list = appointments.where((a) => !up.contains(a)).toList();
    list.sort((a, b) => '${b.date}${b.time}'.compareTo('${a.date}${a.time}'));
    return list;
  }

  Appointment? byId(String? id) {
    if (id == null) return null;
    for (final a in appointments) {
      if (a.id == id) return a;
    }
    return null;
  }

  Appointment? selectedOrFirst(DateTime today) {
    final found = byId(selectedAppointmentId);
    if (found != null) return found;
    final up = upcoming(today);
    if (up.isNotEmpty) return up.first;
    return appointments.isNotEmpty ? appointments.first : null;
  }

  AppointmentsState copyWith({
    List<Appointment>? appointments,
    int? sequence,
    String? segment,
    String? selectedAppointmentId,
    bool? loadingSkeleton,
    DoneScreenData? doneData,
  }) =>
      AppointmentsState(
        appointments: appointments ?? this.appointments,
        sequence: sequence ?? this.sequence,
        segment: segment ?? this.segment,
        selectedAppointmentId:
            selectedAppointmentId ?? this.selectedAppointmentId,
        loadingSkeleton: loadingSkeleton ?? this.loadingSkeleton,
        doneData: doneData ?? this.doneData,
      );

  @override
  List<Object?> get props => [
        appointments,
        sequence,
        segment,
        selectedAppointmentId,
        loadingSkeleton,
        doneData,
      ];
}

sealed class AppointmentsEvent {
  const AppointmentsEvent();
}

class AppointmentsSegmentChanged extends AppointmentsEvent {
  const AppointmentsSegmentChanged(this.segment, {this.withSkeleton = true});
  final String segment;
  final bool withSkeleton;
}

class AppointmentSelected extends AppointmentsEvent {
  const AppointmentSelected(this.appointmentId);
  final String appointmentId;
}

class AppointmentCreated extends AppointmentsEvent {
  const AppointmentCreated({
    required this.appointment,
    required this.doneTitle,
    required this.doneSubtitle,
  });

  final Appointment appointment;
  final String doneTitle;
  final String doneSubtitle;
}

class AppointmentRescheduled extends AppointmentsEvent {
  const AppointmentRescheduled({
    required this.appointmentId,
    required this.newDate,
    required this.newTime,
  });

  final String appointmentId;
  final String newDate;
  final String newTime;
}

class AppointmentCancelled extends AppointmentsEvent {
  const AppointmentCancelled(this.appointmentId, {this.reason = ''});
  final String appointmentId;
  final String reason;
}

class AppointmentCompleted extends AppointmentsEvent {
  const AppointmentCompleted(this.appointmentId);
  final String appointmentId;
}

class AppointmentsDoneShown extends AppointmentsEvent {
  const AppointmentsDoneShown(this.doneData);
  final DoneScreenData doneData;
}

class AppointmentsReset extends AppointmentsEvent {
  const AppointmentsReset({required this.empty});
  final bool empty;
}

class AppointmentsBloc extends Bloc<AppointmentsEvent, AppointmentsState> {
  AppointmentsBloc({required this.clock})
      : super(AppointmentsState(
          appointments: DemoData.mkAppointments(clock.today),
        )) {
    on<AppointmentsSegmentChanged>((event, emit) async {
      if (event.withSkeleton) {
        emit(state.copyWith(segment: event.segment, loadingSkeleton: true));
        await Future<void>.delayed(const Duration(milliseconds: 380));
        emit(state.copyWith(loadingSkeleton: false));
      } else {
        emit(state.copyWith(segment: event.segment, loadingSkeleton: false));
      }
    });
    on<AppointmentSelected>((event, emit) {
      emit(state.copyWith(selectedAppointmentId: event.appointmentId));
    });
    on<AppointmentCreated>((event, emit) {
      final seq = state.sequence + 1;
      final id = event.appointment.id.isEmpty ? 'HU-$seq' : event.appointment.id;
      final created = Appointment(
        id: id,
        kind: event.appointment.kind,
        petId: event.appointment.petId,
        typeId: event.appointment.typeId,
        serviceId: event.appointment.serviceId,
        vetId: event.appointment.vetId,
        walkerId: event.appointment.walkerId,
        clinicId: event.appointment.clinicId,
        date: event.appointment.date,
        time: event.appointment.time,
        endDate: event.appointment.endDate,
        status: event.appointment.status,
        price: event.appointment.price,
        size: event.appointment.size,
        extras: event.appointment.extras,
        pickup: event.appointment.pickup,
        note: event.appointment.note,
        remind: event.appointment.remind,
      );
      emit(state.copyWith(
        sequence: seq,
        appointments: [...state.appointments, created],
        selectedAppointmentId: id,
        doneData: DoneScreenData(
          title: event.doneTitle,
          subtitle: event.doneSubtitle,
          appointmentId: id,
        ),
      ));
    });
    on<AppointmentRescheduled>((event, emit) {
      final next = state.appointments.map((a) {
        if (a.id != event.appointmentId) return a;
        return a.copyWith(date: event.newDate, time: event.newTime);
      }).toList();
      emit(state.copyWith(
        appointments: next,
        selectedAppointmentId: event.appointmentId,
      ));
    });
    on<AppointmentCancelled>((event, emit) {
      final next = state.appointments.map((a) {
        if (a.id != event.appointmentId) return a;
        return a.copyWith(status: AppointmentStatus.cancelled);
      }).toList();
      emit(state.copyWith(appointments: next));
    });
    on<AppointmentCompleted>((event, emit) {
      final next = state.appointments.map((a) {
        if (a.id != event.appointmentId) return a;
        return a.copyWith(status: AppointmentStatus.done);
      }).toList();
      emit(state.copyWith(appointments: next));
    });
    on<AppointmentsDoneShown>((event, emit) {
      emit(state.copyWith(doneData: event.doneData));
    });
    on<AppointmentsReset>((event, emit) {
      emit(state.copyWith(
        appointments: event.empty ? [] : DemoData.mkAppointments(clock.today),
      ));
    });
  }

  final Clock clock;
}
