import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../core/data/demo_data.dart';
import '../../core/domain/models.dart';
import '../../core/utils/clock.dart';

class RemindersState extends Equatable {
  const RemindersState({required this.reminders});
  final List<Reminder> reminders;

  int get pendingCount => reminders.where((r) => !r.done).length;

  @override
  List<Object?> get props => [reminders];
}

sealed class RemindersEvent {
  const RemindersEvent();
}

class ReminderToggled extends RemindersEvent {
  const ReminderToggled(this.id, {this.forceDone});
  final int id;
  final bool? forceDone;
}

class ReminderAdded extends RemindersEvent {
  const ReminderAdded(this.reminder);
  final Reminder reminder;
}

class RemindersReset extends RemindersEvent {
  const RemindersReset({required this.empty});
  final bool empty;
}

class RemindersBloc extends HydratedBloc<RemindersEvent, RemindersState> {
  RemindersBloc({required this.clock})
      : super(RemindersState(reminders: DemoData.mkReminders(clock.today))) {
    on<ReminderToggled>((event, emit) {
      final next = state.reminders.map((r) {
        if (r.id != event.id) return r;
        return r.copyWith(done: event.forceDone ?? !r.done);
      }).toList();
      emit(RemindersState(reminders: next));
    });
    on<ReminderAdded>((event, emit) {
      emit(RemindersState(reminders: [...state.reminders, event.reminder]));
    });
    on<RemindersReset>((event, emit) {
      emit(RemindersState(
        reminders: event.empty ? [] : DemoData.mkReminders(clock.today),
      ));
    });
  }

  final Clock clock;

  @override
  RemindersState? fromJson(Map<String, dynamic> json) {
    try {
      final list = (json['reminders'] as List<dynamic>)
          .map((e) => Reminder.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      return RemindersState(reminders: list);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(RemindersState state) => {
        'reminders': state.reminders.map((e) => e.toJson()).toList(),
      };
}
