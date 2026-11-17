import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/models.dart';
import '../../core/format/hu_format.dart';
import '../../core/utils/clock.dart';

class LiveWalkBlocState extends Equatable {
  const LiveWalkBlocState({
    this.walk,
    this.justCompletedTick = 0,
  });

  final LiveWalk? walk;
  final int justCompletedTick;

  LiveWalkBlocState copyWith({
    LiveWalk? walk,
    bool clearWalk = false,
    int? justCompletedTick,
  }) =>
      LiveWalkBlocState(
        walk: clearWalk ? null : (walk ?? this.walk),
        justCompletedTick: justCompletedTick ?? this.justCompletedTick,
      );

  @override
  List<Object?> get props => [walk, justCompletedTick];
}

sealed class LiveWalkEvent {
  const LiveWalkEvent();
}

class LiveWalkStarted extends LiveWalkEvent {
  const LiveWalkStarted({this.petId = 'milo', this.walkerId = 'diego'});
  final String petId;
  final String walkerId;
}

class LiveWalkTickerStarted extends LiveWalkEvent {
  const LiveWalkTickerStarted();
}

class LiveWalkTickerStopped extends LiveWalkEvent {
  const LiveWalkTickerStopped();
}

class LiveWalkTicked extends LiveWalkEvent {
  const LiveWalkTicked();
}

class LiveWalkRated extends LiveWalkEvent {
  const LiveWalkRated(this.stars);
  final int stars;
}

class LiveWalkCleared extends LiveWalkEvent {
  const LiveWalkCleared();
}

class LiveWalkBloc extends Bloc<LiveWalkEvent, LiveWalkBlocState> {
  LiveWalkBloc({required this.clock}) : super(const LiveWalkBlocState()) {
    on<LiveWalkStarted>((event, emit) {
      if (state.walk != null) return;
      final now = clock.now();
      final startedAt = now.subtract(const Duration(minutes: 18));
      final evMin = startedAt.hour * 60 + startedAt.minute + 9;
      emit(state.copyWith(
        walk: LiveWalk(
          appointmentId: 'HU-LIVE',
          petId: event.petId,
          walkerId: event.walkerId,
          state: LiveWalkState.live,
          progress: 0.32,
          seconds: 18 * 60 + 20,
          events: [
            WalkEvent(
              icon: 'i-drop',
              text: 'Tomó agua',
              time: HuFormat.hm(evMin),
            ),
          ],
        ),
      ));
    });

    on<LiveWalkTickerStarted>((event, emit) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(const LiveWalkTicked());
      });
    });

    on<LiveWalkTickerStopped>((event, emit) {
      _timer?.cancel();
    });

    on<LiveWalkTicked>((event, emit) {
      final w = state.walk;
      if (w == null || w.state != LiveWalkState.live) return;
      final nextSecs = w.seconds + 1;
      final nextProg = math.min(1.0, w.progress + 1.0 / 60.0);
      final events = List<WalkEvent>.from(w.events);
      if (nextProg > 0.55 && events.length == 1) {
        events.add(
          WalkEvent(
            icon: 'i-paw',
            text: 'Hizo sus necesidades',
            time: HuFormat.hm(clock.nowMinutes),
          ),
        );
      }
      final done = nextProg >= 1.0;
      emit(state.copyWith(
        walk: w.copyWith(
          seconds: nextSecs,
          progress: nextProg,
          events: events,
          state: done ? LiveWalkState.done : LiveWalkState.live,
        ),
        justCompletedTick:
            done ? state.justCompletedTick + 1 : state.justCompletedTick,
      ));
      if (done) {
        _timer?.cancel();
      }
    });

    on<LiveWalkRated>((event, emit) {
      final w = state.walk;
      if (w == null) return;
      emit(state.copyWith(walk: w.copyWith(rating: event.stars)));
    });

    on<LiveWalkCleared>((event, emit) {
      _timer?.cancel();
      emit(state.copyWith(clearWalk: true));
    });
  }

  final Clock clock;
  Timer? _timer;

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
